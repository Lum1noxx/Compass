import 'dart:convert';

import 'package:clientapp/data.dart';
import 'package:clientapp/mainActivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
 runApp(const MainApp());
}

class Globals {
  static Future<void> init() async{
    // TODO: collect actual data
    await rootBundle.loadString("assets/json/nodes.json").then((str){
      List<dynamic> json = jsonDecode(str);
      return {
        for (Map<String, dynamic> nodeInfo in json)
        nodeInfo['name'] as String: Node(nodeInfo['name'], Coordinate(nodeInfo['lat'].toDouble(), nodeInfo['lng'].toDouble(), nodeInfo['floor'].toInt()) )
      };
    }).then((map)=>nodes = Nodes(map));
    await rootBundle.loadString("assets/json/destinations.json").then((str){
      List<dynamic> json = jsonDecode(str);
      return {
        for (Map<String, dynamic> destInfo in json)
        destInfo['name'] as String: Destination(destInfo['name'], Coordinate(destInfo['lat'].toDouble(), destInfo['lng'].toDouble(), destInfo['floor'].toInt()) )
      };
    }).then((map)=>destinations = Destinations(map, 4));
  }
  static late Nodes nodes;
  static late Destinations destinations;
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    Globals.init();
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: MainActivity(),
        ),
      ),
    );
  }
}
