import 'dart:convert';
import 'dart:math';

import 'package:clientapp/UserExceptions.dart';
import 'package:clientapp/constants.dart';
import 'package:clientapp/data.dart';
import 'package:http/http.dart';

class ApiCalls {
  static Future<List<Map>> shortest_path(
    String start,
    String end,
    bool allowStairs,
    bool allowUnsheltered,
  ) async {
    print("api call::shortest_path::${start}::${end}");
    Uri request = Uri.https(Constants.baseUrl, "/shortest_path", {
      "start": start.replaceAll(' ', "_"),
      "end": end.replaceAll(' ', "_"),
      // "sheltered" : (!allowUnsheltered).toString(), /// REMOVE BEFORE FLIGHT
      // "stairs" : allowStairs.toString()
    });
    final response = await get(request);
    if (response.statusCode == 200) {
      List<dynamic> json = jsonDecode(response.body)['edges'];
      return [for (dynamic obj in json) obj as Map];
    } else {
      String errorMessage = jsonDecode(response.body)['error'];
      if (errorMessage.toLowerCase() == "you are in the building") {
        // already there
        throw EdgelessPathException();
      } else {
        // impossible
        throw ImpossiblePathException();
      }
    }
    
    // List<Map> json = [ // STUB
    //   {
    //     "type": "walk",
    //     "start": "terrace",
    //     "end": "com3 bus stop",
    //     "sheltered": true,
    //     "stairs": true,
    //     "duration": 60
    //   },
    //   {
    //     "type": "waitForBus",
    //     "start": "com3 bus stop",
    //     "end": "d1 at com3",
    //     "sheltered": true,
    //     "stairs": false,
    //     "duration": 300
    //   },
    //   {
    //     "type": "bus",
    //     "start": "d1 at com3",
    //     "end": "utown bus stop",
    //     "sheltered": true,
    //     "stairs": false,
    //     "duration": 180
    //   },
    //   {
    //     "type": "walk",
    //     "start": "utown bus stop",
    //     "end": "flavours",
    //     "sheltered": false,
    //     "stairs": false,
    //     "duration": 90
    //   }

    // ];
  }

  static Future<List<Map>> node_coordinates(List<String> names) async {
    print("api call::node_coordinates::${names}");
    Uri request = Uri.https(Constants.baseUrl, "/node_coordinates", {
      "names": [for (String name in names) name.replaceAll(' ', "_")],
    });
    final response = await get(request);
    List<dynamic> json = jsonDecode(response.body)['nodes'];
    // List<Map> json = []; // STUB
    // json = [
    //   for (String name in names)
    //     {
    //       "name": name,
    //       "lat": 1.2966 + (Random().nextDouble()-0.5)/50,
    //       "lng": 103.7764 + (Random().nextDouble()-0.5)/50,
    //       "floor": 1
    //     }
    // ];
    return [for (dynamic obj in json) obj as Map];
  }

  static Future<List<Map>> dest_coordinates(List<String> names) async {
    print("api call::dest_coordinates::${names}");
    Uri request = Uri.https(Constants.baseUrl, "/dest_coordinates", {
      "names": [for (String name in names) name.replaceAll(' ', "_")],
    });
    final response = await get(request);
    List<dynamic> json = jsonDecode(response.body)['destinations'];
    // List<Map> json = []; // STUB
    // json = [
    //   for (String name in names)
    //     {
    //       "name": name,
    //       "lat": 1.2966 + (Random().nextDouble()-0.5)/50,
    //       "lng": 103.7764 + (Random().nextDouble()-0.5)/50,
    //       "floor": 1
    //     }
    // ];
    return [for (dynamic obj in json) obj as Map];
  }

  static Future<List<Map<dynamic, dynamic>>> near_destinations(
    double lat,
    double lng,
    int floor,
    int count,
  ) async {
    print("api call::near_destinations::$lat, $lng, $floor, $count");
    Uri request = Uri.https(Constants.baseUrl, "/near_destinations", {
      'lat': lat.toString(),
      'lng': lng.toString(),
      'floor': floor.toString(),
      'count': count.toString(),
    });
    // final response = await get(request);
    // List<dynamic> json = jsonDecode(response.body)['destinations'];

    List<dynamic> json = [
      // STUB
      {
        'name': 'COM1',
        'lat': (lat + (Random().nextDouble() - 0.5) / 500).toString(),
        'lng': (lng + (Random().nextDouble() - 0.5) / 500).toString(),
        'floor': 1,
      },
      {
        'name': 'COM2',
        'lat': (lat + (Random().nextDouble() - 0.5) / 500).toString(),
        'lng': (lng + (Random().nextDouble() - 0.5) / 500).toString(),
        'floor': 1,
      },
      {
        'name': 'COM3',
        'lat': (lat + (Random().nextDouble() - 0.5) / 500).toString(),
        'lng': (lng + (Random().nextDouble() - 0.5) / 500).toString(),
        'floor': 1,
      },
      {
        'name': 'COM4',
        'lat': (lat + (Random().nextDouble() - 0.5) / 500).toString(),
        'lng': (lng + (Random().nextDouble() - 0.5) / 500).toString(),
        'floor': 1,
      },
      {
        'name': 'COM5',
        'lat': (lat + (Random().nextDouble() - 0.5) / 500).toString(),
        'lng': (lng + (Random().nextDouble() - 0.5) / 500).toString(),
        'floor': 1,
      },
    ];
    return [for (dynamic obj in json) obj as Map];
  }
}
