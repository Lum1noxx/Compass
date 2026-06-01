import 'dart:convert';

import 'package:clientapp/apiCalls.dart';
import 'package:clientapp/defaults.dart';
import 'package:flutter/services.dart';
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
    // TODO: implement toString
    return 'node: $name at $coordinate';
  }
  LatLng getLatLng() {
    return coordinate.getLatLng();
  }
}

class Destination {
  const Destination(this.name, this.coordinate);
  final Coordinate coordinate;
  final String name;
  // List<Node> getNodes();
  // Coordinate locate();
  // int numNodes();
  @override
  String toString() {
    // TODO: implement toString
    return 'destination: $name at $coordinate';
  }
  LatLng getLatLng() {
    return coordinate.getLatLng();
  }
}

// class SingleDestination extends Destination {
//   const SingleDestination(super.name, this.node);
//   final Node node;
//   @override
//   List<Node> getNodes() {
//     // TODO: implement getNodes
//     return [node];
//   }
//   @override
//   Coordinate locate() {
//     // TODO: implement locate
//     return node.coordinate;
//   }
//   @override
//   int numNodes() {
//     // TODO: implement numNodes
//     return 1;
//   }
// }

// class GroupDestination extends Destination {
//   const GroupDestination(super.name, this.children);
//   final List<Destination> children;

//   @override
//   List<Node> getNodes() {
//     // TODO: implement getNodes
//     List<Node> nodes = [];
//     for (Destination dest in children) {
//       nodes.addAll(dest.getNodes());
//     }
//     return nodes;
//   }
//   @override
//   Coordinate locate() {
//     // TODO: implement locate
//     double lat = 0;
//     double lng = 0;
//     double floor = 0;
//     for (Destination dest in children) {
//       Coordinate loc = dest.locate();
//       int num = dest.numNodes();
//       lat += loc.lat*num;
//       lng += loc.lng*num;
//       floor += loc.floor*num;
//     }
//     int totalNum = numNodes();
//     return Coordinate(lat/totalNum, lng/totalNum,  (floor/totalNum).round());
//   }

//   @override
//   int numNodes() {
//     // TODO: implement numNodes
//     int num = 0;
//     for (Destination dest in children) {
//       num += dest.numNodes();
//     }
//     return num;
//   }
// }

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
  static EdgeType get(String name) {
    return dict[name]!;
  }
}

class Edge {
  const Edge(this.edgeType, this.start, this.end, this.sheltered, this.stairs, this.duration);
  final EdgeType edgeType;
  final Node start;
  final Node end;
  final bool sheltered;
  final bool stairs;
  final double duration;

  @override
  String toString() {
    return '${edgeType.name} from $start to $end (${duration}s)';
  }
}

class Nodes {
  // name -> Node

  final Map<String, Node> map = {};
  Future<void> fetch (List<String> names) async {
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