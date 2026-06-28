import 'dart:convert';
import 'dart:math';

import 'package:clientapp/UserExceptions.dart';
import 'package:clientapp/constants.dart';
import 'package:clientapp/data.dart';
import 'package:http/http.dart';

/// static-style class for API calls to backend
///
/// arguments are passed as http-native query types,
/// responses are returned as directly-translated values of json types
class ApiCalls {
  /// request for shortest path between start and end [Destination]s, subject to accessibility and shelter constraints
  ///
  /// Args:
  /// - start: name of start [Destination]
  /// - end: name of end [Destination]
  /// - filterStairs: whether to only consider accessible paths
  /// - filterUnsheltered: whether to only consider sheltered paths
  ///
  /// Returns:
  /// - [List] of [Map]s, each representing an [Edge] on the optimal path
  ///
  /// Examples:
  ///   >>> shortest_path("COM3", "COM4", false, false)
  ///   [
  ///       {
  ///           "type": "walk",
  ///           "start": "com3 linkway (com4) entrance",
  ///           "end": "com4 linkway entrance",
  ///           "sheltered": true,
  ///           "stairs": false,
  ///           "duration": 19.5
  ///       },
  ///       {
  ///           "type": "walk",
  ///           "start": "com4 linkway entrance",
  ///           "end": "com4 l2 toilet branch",
  ///           "sheltered": true,
  ///           "stairs": false,
  ///           "duration": 7.5
  ///       }
  ///   ]
  static Future<List<Map>> shortest_path(
    String start,
    String end,
    bool filterStairs,
    bool filterUnsheltered,
  ) async {
    print("api call::shortest_path::${start}::${end}");
    Uri request = Uri.https(Constants.baseUrl, "/shortest_path", {
      "start": start.replaceAll(' ', "_"),
      "end": end.replaceAll(' ', "_"),
      "sheltered": (filterUnsheltered).toString(),

      /// ADD BEFORE FLIGHT
      "stairs": (!filterStairs).toString(),
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

  /// request for shortest path between start [Coordinate] and end [Destination], subject to accessibility and shelter constraints
  ///
  /// Args:
  /// - lat: latitude of start [Coordinate]
  /// - lng: longitude of start [Coordinate]
  /// - floor: floor of start [Coordinate]
  /// - end: name of end [Destination]
  /// - filterStairs: whether to only consider accessible paths
  /// - filterUnsheltered: whether to only consider sheltered paths
  ///
  /// Returns:
  /// - [List] of [Map]s, each representing an [Edge] on the optimal path
  ///
  /// Examples:
  ///   >>> use_location(1.294824, 103.775045, 1, "COM4", false, false)
  ///   [
  ///       {
  ///           "type": "walk",
  ///           "start": "com3 linkway (com4) entrance",
  ///           "end": "com4 linkway entrance",
  ///           "sheltered": true,
  ///           "stairs": false,
  ///           "duration": 19.5
  ///       },
  ///       {
  ///           "type": "walk",
  ///           "start": "com4 linkway entrance",
  ///           "end": "com4 l2 toilet branch",
  ///           "sheltered": true,
  ///           "stairs": false,
  ///           "duration": 7.5
  ///       }
  ///   ]
  static Future<List<Map>> use_location(
    double lat,
    double lng,
    int floor,
    String end,
    bool filterStairs,
    bool filterUnsheltered,
  ) async {
    print("api call::use_location::$lat, $lng, $floor, $end");
    Uri request = Uri.https(Constants.baseUrl, "/use_location", {
      'lat': lat.toString(),
      'lng': lng.toString(),
      'floor': floor.toString(),
      "end": end.replaceAll(' ', "_"),
      "sheltered": (filterUnsheltered).toString(),

      /// ADD BEFORE FLIGHT
      "stairs": (!filterStairs).toString(),
    });
    // return shortest_path("COM3", end, filterStairs, filterUnsheltered); /// REMOVE BEFORE FLIGHT
    final response = await get(request);

    /// ADD BEFORE FLIGHT
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
  }

  /// request for nodes with the given names
  ///
  /// Args:
  /// - names: [List] of node names
  ///
  /// Returns:
  /// - [List] of [Map]s, each representing a [Node]
  ///
  /// Examples:
  ///   >>> node_coordinates(["kr mrt exit a"])
  ///   [
  ///     {
  ///         "name": "kr mrt exit a",
  ///         "lat": "1.2943409261",
  ///         "lng": "103.7846244386",
  ///         "floor": 1
  ///     }
  ///   ]
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
    return [
      for (dynamic obj in json)
        {
          'name': obj['name'],
          'lat': double.parse(obj['lat']),
          'lng': double.parse(obj['lng']),
          'floor': obj['floor'],
        },
    ];
  }

  /// request for destinations with the given names
  ///
  /// Args:
  /// - names: [List] of [Destination] names
  ///
  /// Returns:
  /// - [List] of [Map]s, each representing a [Destination]
  ///
  /// Examples:
  ///   >>> dest_coordinates(["COM3"])
  ///   [
  ///     {
  ///         "name": "COM3",
  ///         "lat": "1.2948846706",
  ///         "lng": "103.7746737202",
  ///         "floor": 1
  ///     }
  ///   ]
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
    return [
      for (dynamic obj in json)
        {
          'name': obj['name'],
          'lat': double.parse(obj['lat']),
          'lng': double.parse(obj['lng']),
          'floor': obj['floor'],
        },
    ];
  }

  /// request for [Destination]s nearest to a given [Coordinate]
  ///
  /// Args:
  /// - lat: latitude of given [Coordinate]
  /// - lng: longitude of given [Coordinate]
  /// - floor: floor of given [Coordinate]
  /// - coount: number of [Destination]s to return
  ///
  /// Returns:
  /// - [List] of [Map]s, each representing a [Destination]
  ///
  /// Examples:
  ///   >>> near_destinations(1.294884, 103.774673, 1, 1)
  ///   [
  ///     {
  ///         "name": "COM3",
  ///         "lat": "1.2948846706",
  ///         "lng": "103.7746737202",
  ///         "floor": 1
  ///     }
  ///   ]
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
    final response = await get(request);
    List<dynamic> json = jsonDecode(response.body)['destinations'];

    // List<dynamic> json = [
    //   /// REMOVE BEFORE FLIGHT
    //   {
    //     'name': 'COM1',
    //     'lat': (lat + (Random().nextDouble() - 0.5) / 500).toString(),
    //     'lng': (lng + (Random().nextDouble() - 0.5) / 500).toString(),
    //     'floor': 1,
    //   },
    //   {
    //     'name': 'COM2',
    //     'lat': (lat + (Random().nextDouble() - 0.5) / 500).toString(),
    //     'lng': (lng + (Random().nextDouble() - 0.5) / 500).toString(),
    //     'floor': 1,
    //   },
    //   {
    //     'name': 'COM3',
    //     'lat': (lat + (Random().nextDouble() - 0.5) / 500).toString(),
    //     'lng': (lng + (Random().nextDouble() - 0.5) / 500).toString(),
    //     'floor': 1,
    //   },
    //   {
    //     'name': 'COM4',
    //     'lat': (lat + (Random().nextDouble() - 0.5) / 500).toString(),
    //     'lng': (lng + (Random().nextDouble() - 0.5) / 500).toString(),
    //     'floor': 1,
    //   },
    //   {
    //     'name': 'COM5',
    //     'lat': (lat + (Random().nextDouble() - 0.5) / 500).toString(),
    //     'lng': (lng + (Random().nextDouble() - 0.5) / 500).toString(),
    //     'floor': 1,
    //   },
    // ];
    return [for (dynamic obj in json) {
      'name' : obj['name'],
      'lat' : double.parse(obj['lat']),
      'lng' : double.parse(obj['lng']),
      'floor' : obj['floor']
    }];
  }
}
