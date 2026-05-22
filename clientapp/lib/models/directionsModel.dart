import 'dart:convert';

import 'package:clientapp/data.dart';
import 'package:clientapp/main.dart';
import 'package:flutter/material.dart';

class DirectionsModel {

  Destination getDest(String destName) {
    return Globals.destinations.get(destName);
  }

  List<String> queryAutocomplete(String query) {
    return Globals.destinations.autocomplete(query);
  }

  Future<List<Edge>> findPath(Destination startDest, Destination endDest) async{
    String request = JsonEncoder().convert({
      "start": startDest.name,
      "end": endDest.name
    });
    // TODO: SEND REQUEST TO BACKEND AND AWAIT RESPONSE
    dynamic response = [ // STUB
      {
        "type": "walk",
        "start": "terrace",
        "end": "com3 bus stop",
        "sheltered": true,
        "stairs": true,
        "duration": 60
      },
      {
        "type": "waitForBus",
        "start": "com3 bus stop",
        "end": "d1 at com3",
        "sheltered": true,
        "stairs": false,
        "duration": 300
      },
      {
        "type": "bus",
        "start": "d1 at com3",
        "end": "utown bus stop",
        "sheltered": true,
        "stairs": false,
        "duration": 180
      },
      {
        "type": "walk",
        "start": "utown bus stop",
        "end": "flavours",
        "sheltered": false,
        "stairs": false,
        "duration": 90
      }

    ];
    return [
      for (Map<String, dynamic> edgeInfo in (response as List))
        Edge(
          EdgeType.get(edgeInfo["type"]),
          Globals.nodes.get(edgeInfo["start"]),
          Globals.nodes.get(edgeInfo["end"]),
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