import 'dart:math';

import 'package:clientapp/apiCalls.dart';
import 'package:clientapp/defaults.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:woozy_search/woozy_results.dart';
import 'package:woozy_search/woozy_search.dart';

/// position based on WGS84 projection and building floor number
///
/// public members:
/// - lat: WGS84 latitude
/// - lng: WGS84 longitude
/// - floor: building floor number
class Coordinate {
  const Coordinate(this.lat, this.lng, this.floor);
  final double lat;
  final double lng;
  final int floor;

  /// obtain [LatLng] representing this WGS84 position
  ///
  /// Args:
  ///
  /// Returns:
  /// - [LatLng]
  LatLng getLatLng() {
    return LatLng(lat, lng);
  }

  @override
  String toString() {
    return 'Floor ${Floors.getName(floor)} at ($lat, $lng)';
  }
}

/// generic named position at a [Coordinate], used to form [Edge]s
///
/// instances are shared and not copied
///
/// public members:
/// - name: [String]
/// - coordinate: [Coordinate]
class Node {
  const Node(this.name, this.coordinate);
  final String name;
  final Coordinate coordinate;

  @override
  String toString() {
    return 'node: $name at $coordinate';
  }

  /// obtain [LatLng] representing this WGS84 position
  ///
  /// Returns:
  /// - [LatLng]
  LatLng getLatLng() {
    return coordinate.getLatLng();
  }
}

/// special [Node] representing a notable place
class Destination extends Node {
  const Destination(super.name, super.coordinate);

  @override
  String toString() {
    return '$name: $coordinate';
  }
}

/// action associated with an [Edge]
enum EdgeType {
  walk,
  bus,
  lift,
  waitForBus,
  waitForLift;

  static final Map<String, EdgeType> dict = {
    for (EdgeType edgeType in EdgeType.values) edgeType.name: edgeType,
  };
  static final Map<EdgeType, EdgeType> relatedTypes = {
    walk: walk,
    bus: bus,
    lift: lift,
    waitForBus: bus,
    waitForLift: lift,
  };

  /// obtain [EdgeType] with the given name
  ///
  /// Args:
  /// - name: [String]
  ///
  /// Returns:
  /// - [EdgeType]
  static EdgeType get(String name) {
    return dict[name]!;
  }

  /// determine whether this is related to another [EdgeType]
  ///
  /// two [EdgeType]s are related if they are equal, or if an [Edge] of one [EdgeType] is always adjacent to an [Edge] of the other [EdgeType]
  ///
  /// Args:
  /// - other: other [EdgeType]
  ///
  /// Returns:
  /// - whether this is related to [other]
  bool isRelatedTo(EdgeType other) {
    return EdgeType.relatedTypes[this] == EdgeType.relatedTypes[other];
  }

  /// obtain the root [EdgeType] of this
  ///
  /// an [EdgeType] is either equal to its root, or any [Edge] with that [EdgeType] is always adjacent to an [Edge] whose type is its root
  ///
  /// Returns:
  /// - root [EdgeType]
  EdgeType rootType() {
    return EdgeType.relatedTypes[this]!;
  }
}

/// time-weighted action connection between two [Node]s
///
/// main constituent of [Segment]s and [Path]s. instances are shared and not copied.
///
/// public members:
/// - edgeType: action associated with this
/// - start: starting [Node]
/// - end: ending [Node]
/// - sheltered: whether this action is sheltered
/// - stairs: whether this action is not accessibility-friendly (as it involves stairs)
/// - duration: time taken to complete this action
class Edge {
  final EdgeType edgeType;
  final Node start;
  final Node end;
  final bool sheltered;
  final bool stairs;
  final double duration;

  const Edge(
    this.edgeType,
    this.start,
    this.end,
    this.sheltered,
    this.stairs,
    this.duration,
  );

  @override
  String toString() {
    return '${edgeType.name} from $start to $end (${duration}s)';
  }

  /// determine whether this [EdgeType] is related to another [Edge]'s [EdgeType]
  ///
  /// Args:
  /// - other: other [Edge]
  ///
  /// Returns:
  /// - whether this [EdgeType] is related to [other]'s [EdgeType]
  bool isRelatedTo(Edge other) {
    return edgeType.isRelatedTo(other.edgeType);
  }
}

/// in-memory repository of [Node]s
///
/// Does not store any subtype instances. Intially empty. [Node]s are cached when created on first access, ensuring safe sharing of references.
class Nodes {
  final Map<String, Node> map = {};

  /// create [Node]s with the given names by requesting data from backend
  ///
  /// skips any [Node]s that already exist in this
  ///
  /// Args:
  /// - names: [List] of names of [Node]s to create
  Future<void> fetch(List<String> names) async {
    names = [
      for (String name in names)
        if (!map.containsKey(name)) name,
    ];
    List<Map> json = await ApiCalls.node_coordinates(names);
    for (Map nodeObj in json) {
      map[nodeObj['name']] = Node(
        nodeObj['name'],
        Coordinate(nodeObj['lat'], nodeObj['lng'], nodeObj['floor']),
      );
    }
  }

  /// obtain the [Node] with the given name
  ///
  /// IFF the [Node] does not exist, create it by requesting data from backend
  ///
  /// Args:
  /// - name: name of requested [Node]
  ///
  /// Returns:
  /// - requested [Node]
  Future<Node> get(String name) async {
    if (!map.containsKey(name)) {
      await fetch([name]);
    }
    return map[name]!;
  }
}

/// in-memory repository of [Destination]s with autocomplete name query
///
/// Does not store any subtype instances. Intially empty. [Destination]s are cached when created on first access, ensuring safe sharing of references.
class Destinations {
  /// Args:
  /// - names: all possible [Destination] names
  /// - autocompleteSize: how many suggestions to return for [autocomplete]
  ///
  /// Returns:
  /// - requested [Node]
  Destinations(this.names, this.autocompleteSize) {
    autocompleteEngine = Woozy(limit: autocompleteSize, caseSensitive: false);
    autocompleteEngine.addEntries([
      for (String name in names) name.replaceAll(" ", "_"),
    ]);
  }
  final int autocompleteSize;
  final List<String> names;
  final Map<String, Destination> map = {};
  late Woozy autocompleteEngine;

  /// create [Destination]s with the given names by requesting data from backend
  ///
  /// skips any [Destination]s that already exist in this
  ///
  /// Args:
  /// - names: [List] of names of [Destination]s to create
  Future<void> fetch(List<String> names) async {
    names = [
      for (String name in names)
        if (!map.containsKey(name)) name,
    ];
    List<Map> json = await ApiCalls.dest_coordinates(names);
    for (Map destObj in json) {
      map[destObj['name']] = Destination(
        destObj['name'],
        Coordinate(destObj['lat'], destObj['lng'], destObj['floor']),
      );
    }
  }

  /// obtain the [Destination] with the given name
  ///
  /// IFF the [Destination] does not exist, create it by requesting data from backend
  ///
  /// Args:
  /// - name: name of requested [Destination]
  ///
  /// Returns:
  /// - requested [Destination]
  Future<Destination> get(String name) async {
    if (!map.containsKey(name)) {
      await fetch([name]);
    }
    return map[name]!;
  }

  /// retrieve autocomplete suggestions for a partial destination name input
  ///
  /// Args:
  /// - query: partial destination name input
  ///
  /// Returns:
  /// - [List] of suggested destination names
  List<String> autocomplete(String query) {
    query = query.replaceAll(" ", "_");
    return [
      for (MatchResult res in autocompleteEngine.search(query))
        res.text.replaceAll("_", " "),
    ];
  }

  /// retrieve [Destination]s nearest to selected [Coordinate]
  ///
  /// creates and caches any [Destination]s that do not already exist in this; otherwise, re-use existing [Destination]s
  ///
  /// Args:
  /// - coordinate: selected [Coordinate]
  /// - count: number of [Destination]s to return
  ///
  /// Returns:
  /// - [List] of destinations
  Future<List<Destination>> getNearby(Coordinate coordinate, int count) async {
    List<Map> json = await ApiCalls.near_destinations(
      coordinate.lat,
      coordinate.lng,
      coordinate.floor,
      count,
    );
    List<Destination> res = [];

    for (Map obj in json) {
      map.putIfAbsent(
        obj['name'],
        () => Destination(
          obj['name'],
          Coordinate(obj['lat'], obj['lng'], obj['floor']),
        ),
      );
      res.add(map[obj['name']]!);
    }

    for (Destination destination in res) {
      map.putIfAbsent(destination.name, () => destination);
    }
    return res;
  }
}

/// section of adjacent [Edge]s with related [EdgeType]s
///
/// public members
/// - previous: previous [Segment] along the [Path], if any
/// - next: next [Segment] along the [Path], if any
/// - edges: [List] of adjacent [Edge]s that comprise this
/// - duration: total duration of this [Edge]s
class Segment {
  /// link segments along a [Path]
  ///
  /// Args:
  /// - route: [List] of [Segment]s comprising the [Path]
  static void link(List<Segment> route) {
    if (route.length < 2) {
      return;
    }
    for (int i = 1; i < route.length - 1; i++) {
      route[i].previous = route[i - 1];
      route[i].next = route[i + 1];
    }
    route[0].next = route[1];
    route[route.length - 1].previous = route[route.length - 2];
  }

  Segment? previous;
  Segment? next;
  late final List<Edge> edges;
  late double duration;

  Segment(this.edges) {
    duration = 0;
    for (Edge edge in edges) {
      duration += edge.duration;
    }
  }

  /// creates a [Segment] with a single [Edge]
  ///
  /// Args:
  /// - edge: the only [Edge] in this
  Segment.single(Edge edge) {
    edges = [edge];
    duration = edge.duration;
  }

  /// obtain the [LatLngBounds] which bounds all [Node]s in this, with fixed padding
  ///
  /// Returns:
  /// - [LatLngBounds]
  LatLngBounds getBounds() {
    double n = -1;
    double s = 1_000_000;
    double e = -1;
    double w = 1_000_000;
    for (Node node in [for (Edge edge in edges) edge.start, edges.last.end]) {
      n = max(n, node.coordinate.lat);
      s = min(s, node.coordinate.lat);
      e = max(e, node.coordinate.lng);
      w = min(w, node.coordinate.lng);
    }
    return LatLngBounds(LatLng(n, w), LatLng(s, e));
  }

  /// obtain the first [Node] in this
  ///
  /// Returns:
  /// - [Node]
  Node start() {
    return edges.first.start;
  }

  /// obtain the last [Node] in this
  ///
  /// Returns:
  /// - [Node]
  Node end() {
    return edges.last.end;
  }

  /// obtain the root [EdgeType] of all this [Edge]s
  ///
  /// Returns:
  /// - [EdgeType]
  EdgeType edgeType() {
    return edges.first.edgeType.rootType();
  }
}

/// Adjacent [Segment]s which form a path between start and end [Node]s
///
/// public members:
/// - edges: constituent [Edge]s
/// - segments: constituent [Segment]s
/// - duration: total duration of [segments]
class Path {
  /// classify adjacent [Edge]s into linked [Segment]s
  ///
  /// Args:
  /// - edges: adjacent [Edge]s which comprise a path
  ///
  /// Returns:
  /// - [List] of adjacent [Segment]s which comprise the same path as [edges]
  static List<Segment> group(List<Edge> edges) {
    if (edges.isEmpty) {
      return [];
    }
    List<Segment> segments = [];
    List<Edge> nextSegment = [];
    for (Edge edge in edges) {
      if (nextSegment.isEmpty || nextSegment.last.isRelatedTo(edge)) {
        nextSegment.add(edge);
      } else {
        segments.add(Segment(nextSegment));
        nextSegment = [edge];
      }
    }
    segments.add(Segment(nextSegment));
    Segment.link(segments);
    return segments;
  }

  List<Edge> edges;
  late final List<Segment> segments;
  final Map<Edge, Segment> _edgesIndex = {};
  final Map<Node, Segment> _nodesIndex = {};
  double duration = 0;

  Path(this.edges) {
    if (edges.isEmpty) {
      segments = [];
      return;
    }
    assert(edges.first.start is Destination && edges.last.end is Destination);
    segments = group(edges);
    _nodesIndex[segments.first.start()] = segments.first;
    for (Segment segment in segments) {
      duration += segment.duration;
      for (Edge edge in segment.edges) {
        _edgesIndex[edge] = segment;
        _nodesIndex[edge.end] = segment;
      }
    }
  }

  /// Connect start and end [Destination]s to a [List] of adjacent [Edge]s to form a complete path between start and end
  ///
  /// Args:
  /// - edges: partial [List] of adjacent [Edge]s, exclusing [start] and [end]
  /// - start: start [Destination] of this
  /// - end: final [Destination] of this
  Path.autoJoin(this.edges, Destination start, Destination end) {
    if (edges.isEmpty) {
      edges = [
        Edge(
          EdgeType.walk,
          start,
          end,
          true,
          false,
          DistanceHaversine().distance(start.getLatLng(), end.getLatLng()) /
              Defaults.walkingSpeedMetresPerSec,
        ),
      ];
    } else {
      edges = [
        Edge(
          EdgeType.walk,
          start,
          edges.first.start,
          edges.first.sheltered,
          edges.first.stairs,
          DistanceHaversine().distance(
                start.getLatLng(),
                edges.first.start.getLatLng(),
              ) /
              Defaults.walkingSpeedMetresPerSec,
        ),
        for (Edge edge in edges) edge,
        Edge(
          EdgeType.walk,
          edges.last.end,
          end,
          edges.last.sheltered,
          edges.last.stairs,
          DistanceHaversine().distance(
                edges.last.end.getLatLng(),
                end.getLatLng(),
              ) /
              Defaults.walkingSpeedMetresPerSec,
        ),
      ];
    }
    segments = group(edges);
    _nodesIndex[segments.first.start()] = segments.first;
    for (Segment segment in segments) {
      duration += segment.duration;
      for (Edge edge in segment.edges) {
        _edgesIndex[edge] = segment;
        _nodesIndex[edge.end] = segment;
      }
    }
  }

  /// obtain number of edges in this
  ///
  /// Returns:
  /// - [int]
  int length() {
    return edges.length;
  }

  /// obtain start [Destination] of this
  ///
  /// Returns:
  /// - [Destination]
  Destination start() {
    return edges.first.start as Destination;
  }

  /// obtain end [Destination] of this
  ///
  /// Returns:
  /// - [Destination]
  Destination end() {
    return edges.last.end as Destination;
  }

  /// find the [Segment] which contains the given [Node] or [Edge]
  ///
  /// if [item] is adjacent to two [Segment]s, find the [Segment] that precedes [item]
  ///
  /// Args:
  /// - item: [Node] or [Edge]
  ///
  /// Returns:
  /// - [Segment]
  /// - or [null], if not found
  Segment? locate(dynamic item) {
    if (item == null) {
      return null;
    }
    if (item is Edge) {
      return _edgesIndex[item];
    } else if (item is Node) {
      return _nodesIndex[item];
    } else {
      throw UnsupportedError("can only locate segment of node or edge");
    }
  }

  /// check whether this path connects [start] and [end] non-trivially
  ///
  /// Returns:
  /// - [bool]
  bool isValid() {
    return true;
  }
}

/// represents the lack of a [Path]
///
/// essentially, a [Path] from "nowhere" to "nowhere"
class EmptyPath extends Path {
  EmptyPath() : super([]);

  @override
  int length() {
    return 0;
  }

  @override
  bool isValid() {
    return false;
  }
}

/// trivial [Path]
///
/// this means that either [start] == [end] or one contains the other
class EdgelessPath extends Path {
  EdgelessPath(Destination start, Destination end)
    : super.autoJoin([], start, end);

  @override
  int length() {
    return 0;
  }

  @override
  bool isValid() {
    return false;
  }
}

/// erroneous [Path]
///
/// this means that no path was found that connects [start] and [end]
class ImpossiblePath extends Path {
  late Destination startDest;
  late Destination endDest;
  ImpossiblePath(Destination start, Destination end) : super([]) {
    startDest = start;
    endDest = end;
  }

  @override
  int length() {
    return 0;
  }

  @override
  bool isValid() {
    return false;
  }

  @override
  Destination end() {
    return endDest;
  }

  @override
  Destination start() {
    return endDest;
  }
}

/// utility tools involving floors
class Floors {
  /// obtain the reader-friendly name of a floor number
  ///
  /// Args:
  /// - floor: floor number
  ///
  /// Returns:
  /// - reader-friendly name
  static String getName(int floor) {
    if (floor < 0) {
      return 'B${-floor}';
    } else {
      return 'L${floor}';
    }
  }

  /// obtain the floor number associated with its reader-friendly name
  ///
  /// Args:
  /// - name: [String]
  ///
  /// Returns:
  /// - floor number
  static int getFloor(String name) {
    int abs = int.parse(name.substring(1, name.length));
    if (name[0] == 'B') {
      return -abs;
    } else {
      return abs;
    }
  }
}

/// [Destination] for user-selected [Coordinate]
class TempDestination extends Destination {
  /// use a [Coordinate] at a specific floor
  ///
  /// Args:
  /// - coordinate: [Coordinate]
  TempDestination(Coordinate coordinate)
    : super(coordinate.toString(), coordinate);

  /// use a [LatLng] position without specifying a floor
  ///
  /// Args:
  /// - position: [LatLng] position
  TempDestination.plane(LatLng position)
    : super(
        "(${position.latitude}, ${position.longitude})",
        Coordinate(position.latitude, position.longitude, 0),
      );
}
