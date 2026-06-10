import 'dart:math';

import 'package:clientapp/apiCalls.dart';
import 'package:clientapp/defaults.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:woozy_search/woozy_results.dart';
import 'package:woozy_search/woozy_search.dart';

class Coordinate {
  const Coordinate(this.lat, this.lng, this.floor);
  final double lat;
  final double lng;
  final int floor;

  LatLng getLatLng() {
    return LatLng(lat, lng);
  }

  @override
  String toString() {
    // TODO: implement toString
    return '($lat, $lng), floor $floor';
  }
}

class Node {
  const Node(this.name, this.coordinate);
  final String name;
  final Coordinate coordinate;
  @override
  String toString() {
    return 'node: $name at $coordinate';
  }
  LatLng getLatLng() {
    return coordinate.getLatLng();
  }
}

class Destination extends Node {

  const Destination(super.name, super.coordinate);

  @override
  String toString() {
    return 'destination: $name at $coordinate';
  }

}

enum EdgeType {
  walk,
  bus,
  lift,
  waitForBus,
  waitForLift;

  static final Map<String, EdgeType> dict = {
    for (EdgeType edgeType in EdgeType.values)
      edgeType.name: edgeType
  };
  static final Map<EdgeType, EdgeType> relatedTypes = {
    walk : walk,
    bus : bus,
    lift : lift,
    waitForBus : bus,
    waitForLift : lift
  };

  static EdgeType get(String name) {
    return dict[name]!;
  }

  bool isRelatedTo(EdgeType other) {
    return EdgeType.relatedTypes[this] == EdgeType.relatedTypes[other];
  } 

}

class Edge {
  final EdgeType edgeType;
  final Node start;
  final Node end;
  final bool sheltered;
  final bool stairs;
  final double duration;

  const Edge(this.edgeType, this.start, this.end, this.sheltered, this.stairs, this.duration);

  @override
  String toString() {
    return '${edgeType.name} from $start to $end (${duration}s)';
  }

  bool isSegmentRelatedTo(Edge other) {
    return edgeType.isRelatedTo(other.edgeType);
  }
}

class Nodes {
  // name -> Node

  final Map<String, Node> map = {};
  Future<void> fetch (List<String> names) async {
    names = [
      for (String name in names)
        if (!map.containsKey(name))
          name
    ];
    List<Map> json = await ApiCalls.node_coordinates(names);
    for (Map nodeObj in json) {
      map[nodeObj['name']] = Node(
        nodeObj['name'],
        Coordinate(double.parse(nodeObj['lat']), double.parse(nodeObj['lng']), nodeObj['floor'])
      );
    }
  } 
  Future<Node> get (String name) async{
    if (!map.containsKey(name)) {
      await fetch([name]);
    }
    return map[name]!;
  }

}

class Destinations {
  // name -> Destination
  // Trie<name>
  Destinations(this.names, this.autocompleteSize) {
    autocompleteEngine = Woozy(limit: autocompleteSize, caseSensitive: false);
    autocompleteEngine.addEntries([
      for (String name in names)
        name.replaceAll(" ", "_")
    ]);
  }
  final int autocompleteSize;
  final List<String> names;
  final Map<String, Destination> map = {};
  late Woozy autocompleteEngine;
  
  Future<void> fetch (List<String> names) async {
    names = [
      for (String name in names)
        if (!map.containsKey(name))
          name
    ];
    List<Map> json = await ApiCalls.dest_coordinates(names);
    for (Map destObj in json) {
      map[destObj['name']] = Destination(
        destObj['name'],
        Coordinate(double.parse(destObj['lat']), double.parse(destObj['lng']), destObj['floor'])
      );
    }
  } 

  Future<Destination> get (String name) async{
    if (!map.containsKey(name)) {
      await fetch([name]);
    }
    return map[name]!;
  }
  List<String> autocomplete(String query) {
    query = query.replaceAll(" ", "_");
    return [
      for (MatchResult res in autocompleteEngine.search(query))
        res.text.replaceAll("_", " ")
    ];
  }

  Future<List<Destination>> getNearby(Coordinate coordinate, int count) async {
    List<Map> json = await ApiCalls.near_destinations(
      coordinate.lat,
      coordinate.lng,
      coordinate.floor,
      count
    );
    List<Destination> res = [
      for (Map obj in json)
        Destination(
          obj['name'],
          Coordinate(
            double.parse(obj['lat']),
            double.parse(obj['lng']),
            obj['floor']
          )
        )
    ];
    for (Destination destination in res) {
      map.putIfAbsent(destination.name, ()=>destination);
    }
    return [
      for (Destination destination in res) 
        map[destination.name]!
    ];
  }
}

class Segment {
  
  late final List<Edge> edges;
  late double duration;

  Segment(this.edges) {
    duration = 0;
    for (Edge edge in edges) {
      duration += edge.duration;
    }
  }
  Segment.single(Edge edge) {
    edges = [edge];
    duration = edge.duration;
  }

  LatLngBounds getBounds() {
    double n = -1;
    double s = 1_000_000;
    double e = -1;
    double w = 1_000_000;
    for (Node node in [
      for (Edge edge in edges)
        edge.start,
      edges.last.end
    ]) {
      n = max(n, node.coordinate.lat);
      s = min(s, node.coordinate.lat);
      e = max(e, node.coordinate.lng);
      w = min(w, node.coordinate.lng);
    }
    return LatLngBounds(LatLng(n, w), LatLng(s, e));
  }

  Node start() {
    return edges.first.start;
  }

  Node end() {
    return edges.last.end;
  }

  EdgeType edgeType() {
    return edges.first.edgeType;
  }

}

class Path {

  static List<Segment> group(List<Edge> edges) {
    if (edges.isEmpty) {
      return [];
    }
    List<Segment> segments =[];
    List<Edge> nextSegment = [];
    for (Edge edge in edges) {
      if (nextSegment.isEmpty || nextSegment.last.isSegmentRelatedTo(edge)) {
        nextSegment.add(edge);
      } else {
        segments.add(Segment(nextSegment));
        nextSegment = [edge];
      }
    }
    segments.add(Segment(nextSegment));
    return segments;
  }
  
  List<Edge> edges;
  late final List<Segment> segments;
  final Map<Edge, Segment> _map = {};

  Path(this.edges) {
    if (edges.isEmpty) {
      segments = [];
      return;
    }
    assert(edges.first.start is Destination && edges.last.end is Destination);
    segments = group(edges);
    for (Segment segment in segments) {
      for (Edge edge in segment.edges) {
        _map[edge] = segment;
      }
    }
  }
  Path.autoJoin(this.edges, Destination start, Destination end) {
    if (edges.isEmpty) {
      edges = [
        Edge(
          EdgeType.walk, start, end, true, false,
          DistanceHaversine().distance(start.getLatLng(), end.getLatLng()) / Defaults.walkingSpeedMetresPerSec
        )
      ];
    } else {
      edges = [
        Edge(
          EdgeType.walk, start, edges.first.start, edges.first.sheltered, edges.first.stairs,
          DistanceHaversine().distance(start.getLatLng(), edges.first.start.getLatLng()) / Defaults.walkingSpeedMetresPerSec
        ),
        for (Edge edge in edges)
          edge,
        Edge(
          EdgeType.walk, edges.last.end, end, edges.last.sheltered, edges.last.stairs,
          DistanceHaversine().distance(edges.last.end.getLatLng(), end.getLatLng()) / Defaults.walkingSpeedMetresPerSec
        )
      ];
    }
    segments = group(edges);
    for (Segment segment in segments) {
      for (Edge edge in segment.edges) {
        _map[edge] = segment;
      }
    }
  }

  int length() {
    return edges.length;
  }

  Destination start() {
    return edges.first.start as Destination;
  }
  
  Destination end() {
    return edges.last.end as Destination;
  }

  Segment locate (Edge edge) {
    return _map[edge]!;
  }

}


class Floors {
  static String getName(int floor) {
    if (floor < 0) {
      return 'B${-floor}';
    } else {
      return 'L${floor}';
    }
  }
  static int getFloor(String name) {
    int abs = int.parse(name.substring(1, name.length));  
    if (name[0] == 'B') {
      return -abs;
    } else {
      return abs;
    }
  }
}

class TempDestination extends Destination {
  /// this is soley for highlighting on map
  TempDestination(Coordinate coordinate) : super("", coordinate);
  TempDestination.plane(LatLng position) : super("", Coordinate(position.latitude, position.longitude, 0));
}