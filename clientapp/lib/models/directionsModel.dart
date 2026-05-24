import 'dart:convert';

import 'package:clientapp/apiCalls.dart';
import 'package:clientapp/data.dart';
import 'package:clientapp/main.dart';
import 'package:flutter/material.dart';

class DirectionsModel {

  Future<Destination> getDest(String destName) async{
    return Globals.destinations.get(destName);
  }

  List<String> queryAutocomplete(String query) {
    return Globals.destinations.autocomplete(query);
  }

  Future<List<Edge>> findPath(Destination startDest, Destination endDest) async{
    
    return [
      for (Map edgeInfo in (await ApiCalls.shortest_path(startDest.name, endDest.name) as List))
        Edge(
          EdgeType.get(edgeInfo["type"]),
          await Globals.nodes.get(edgeInfo["start"]),
          await Globals.nodes.get(edgeInfo["end"]),
          edgeInfo["sheltered"],
          edgeInfo["stairs"],
          edgeInfo["duration"]
        )
    ];

  }

  Node getNodeInPath(List<Edge> path, String nodeName) {
    Map<String, Node> nodes = {
      for (Edge edge in path)
        edge.start.name : edge.start,
      path.last.end.name : path.last.end
    };
    return nodes[nodeName]!;
  }

}