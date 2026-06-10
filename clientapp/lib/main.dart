import 'dart:convert';
import 'dart:ui';

import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/mainActivity.dart';
import 'package:clientapp/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MainApp());
}

class Globals {
  static Future<void> init() async {
    // await rootBundle.loadString("assets/json/nodes.json").then((str){
    //   List<dynamic> json = jsonDecode(str);
    //   return {
    //     for (Map<String, dynamic> nodeInfo in json)
    //     nodeInfo['name'] as String: Node(nodeInfo['name'], Coordinate(nodeInfo['lat'].toDouble(), nodeInfo['lng'].toDouble(), nodeInfo['floor'].toInt()) )
    //   };
    // }).then((map)=>nodes = Nodes(map));
    nodes = Nodes();
    await rootBundle.loadString("assets/json/destinations.json").then((str) {
      List rawJson = jsonDecode(str);
      List<String> json = [for (dynamic name in rawJson) name as String];
      destinations = Destinations(json, Defaults.autocompleteSize);
    });
  }

  static late Nodes nodes;
  static late Destinations destinations;
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    Globals.init();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppTheme.init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    AppTheme.init(context);
    return MaterialApp(
      themeMode: ThemeMode.system,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
      ),
      home: Scaffold(body: MainActivity()),
    );
  }
}
