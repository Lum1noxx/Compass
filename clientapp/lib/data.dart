import 'dart:convert';

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
  final int duration;

  @override
  String toString() {
    return '${edgeType.name} from $start to $end (${duration}s)';
  }
}

class Nodes {
  // name -> Node
  Nodes(this.map);

  final Map<String, Node> map;
  Node get(String name) {
    return map[name]!;
  }
}

class Destinations {
  // name -> Destination
  // Trie<name>
  Destinations(this.map, this.autocompleteSize) {
    autocompleteEngine = Woozy(limit: autocompleteSize);
    autocompleteEngine.addEntries(map.keys.toList());
  }
  final int autocompleteSize;
  final Map<String, Destination> map;
  late Woozy autocompleteEngine;

  Destination get(String name) {
    return map[name]!;
  }
  List<String> autocomplete(String query) {
    return [
      for (MatchResult res in autocompleteEngine.search(query))
        res.text
    ];
  }
}