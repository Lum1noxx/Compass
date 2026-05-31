import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart';

class ApiCalls {
  static String baseUrl = "shrubs-quickly-anaerobic.ngrok-free.dev"; // STUB
  static Future<List<Map>> shortest_path (String start, String end) async{
    print("api call::shortest_path::${start}::${end}");
    Uri request = Uri.https(baseUrl, "/shortest_path", {
      "start": start.replaceAll(' ', "_"),
      "end" : end.replaceAll(' ', "_")
    });
    final response = await get(request);
    List<dynamic> json = jsonDecode(response.body)['edges'];
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
    return [
      for (dynamic obj in json)
        obj as Map
    ];
  }

  static Future<List<Map>> node_coordinates (List<String> names) async{
    print("api call::node_coordinates::${names}");
    Uri request = Uri.https(baseUrl, "/node_coordinates", {
      "names": [
        for (String name in names)
          name.replaceAll(' ', "_")
      ]
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
    return [
      for (dynamic obj in json)
        obj as Map
    ];
  }

  static Future<List<Map>> dest_coordinates (List<String> names) async{
    print("api call::dest_coordinates::${names}");
    Uri request = Uri.https(baseUrl, "/dest_coordinates", {
      "names": [
        for (String name in names)
          name.replaceAll(' ', "_")
      ]
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
    return [
      for (dynamic obj in json)
        obj as Map
    ];
  }
}
