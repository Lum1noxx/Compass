import 'dart:convert';
import 'dart:math';

import 'package:clientapp/UserExceptions.dart';
import 'package:clientapp/constants.dart';
import 'package:clientapp/data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

/// static-style class for API calls to backend
///
/// arguments are passed as http-native query types,
/// responses are returned as directly-translated values of json types
class ApiCalls {
  /// heartbeat request to wake up backend server
  static void heartbeat() {
    Uri request = Uri.https(Constants.baseUrl, "/heartbeat");
    get(request);
  }

  /// request for shortest path between start and end [Destination]s, subject to accessibility and shelter constraints
  ///
  /// Args:
  /// - start: name of start [Destination]
  /// - end: name of end [Destination]
  /// - filterStairs: [FilterLevel] for considering accessible paths
  /// - filterUnsheltered: [FilterLevel] for considering sheltered paths
  ///
  /// Returns:
  /// - [Map]
  ///
  /// Examples:
  ///   >>> shortest_path("COM3", "COM4", FilterLevel.prefer, FilterLevel.strict)
  ///   {
  ///     "edges": [
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
  ///     ],
  ///     "shelterPref": 1,
  ///     "stairsPref": 2
  ///   }
  static Future<Map> shortest_path(
    String start,
    String end,
    FilterLevel filterStairs,
    FilterLevel filterUnsheltered,
  ) async {
    Uri request = Uri.https(Constants.baseUrl, "/shortest_path", {
      "start": start.replaceAll(' ', "_"),
      "end": end.replaceAll(' ', "_"),
      "shelterPref": filterUnsheltered.level.toString(),
      "stairsPref": filterStairs.level.toString(),
    });

    final response = await get(request);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
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

  /// request for shortest path between start [Coordinate] and end [Destination], subject to accessibility and shelter constraints
  ///
  /// Args:
  /// - lat: latitude of start [Coordinate]
  /// - lng: longitude of start [Coordinate]
  /// - floor: floor of start [Coordinate]
  /// - end: name of end [Destination]
  /// - filterStairs: [FilterLevel] for considering accessible paths
  /// - filterUnsheltered: [FilterLevel] for considering sheltered paths
  ///
  /// Returns:
  /// - [Map]
  ///
  /// Examples:
  ///   >>> use_location(1.294824, 103.775045, 1, "COM4",  FilterLevel.prefer, FilterLevel.strict)
  ///   {
  ///     "edges": [
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
  ///     ],
  ///     "shelterPref": 1,
  ///     "stairsPref": 2
  ///   }
  static Future<Map> use_location(
    double lat,
    double lng,
    int floor,
    String end,
    FilterLevel filterStairs,
    FilterLevel filterUnsheltered,
  ) async {
    Uri request = Uri.https(Constants.baseUrl, "/use_location", {
      'lat': lat.toString(),
      'lng': lng.toString(),
      'floor': floor.toString(),
      "end": end.replaceAll(' ', "_"),
      "shelterPref": filterUnsheltered.level.toString(),
      "stairsPref": filterStairs.level.toString(),
    });

    final response = await get(request);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
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
    Uri request = Uri.https(Constants.baseUrl, "/node_coordinates", {
      "names": [for (String name in names) name.replaceAll(' ', "_")],
    });
    final response = await get(request);
    List<dynamic> json = jsonDecode(response.body)['nodes'];
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
    Uri request = Uri.https(Constants.baseUrl, "/dest_coordinates", {
      "names": [for (String name in names) name.replaceAll(' ', "_")],
    });
    final response = await get(request);
    List<dynamic> json = jsonDecode(response.body)['destinations'];
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
    Uri request = Uri.https(Constants.baseUrl, "/near_destinations", {
      'lat': lat.toString(),
      'lng': lng.toString(),
      'floor': floor.toString(),
      'count': count.toString(),
    });
    final response = await get(request);
    List<dynamic> json = jsonDecode(response.body)['destinations'];
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

  /// request for vacant [Venue]s nearest to a given [Coordinate]
  ///
  /// Args:
  /// - lat: latitude of given [Coordinate]
  /// - lng: longitude of given [Coordinate]
  /// - count: number of [Venue]s to return
  /// - dayOfWeek: [String] name of day of week (e.g. "Monday")
  /// - start: start [TimeOfDay] for vacancy query
  /// - end: end [TimeOfDay] for vacancy query
  ///
  /// Returns:
  /// - [List] of [Map]s, each representing a [Venue]
  ///
  /// Examples:
  ///   >>> near_rooms(1.294884, 103.774673, 1, "Monday", 1230, 1500)
  ///   [
  ///     {
  ///         "name": "COM3",
  ///         "lat": 1.2948846706,
  ///         "lng": 103.7746737202,
  ///         "floor": 1,
  ///         "occupied": [
  ///           {
  ///             "from": '08:00:00',
  ///             "to": '12:00:00'
  ///           },
  ///           {
  ///             "from": '16:00:00',
  ///             "to": '18:00:00'
  ///           }
  ///         ]
  ///     }
  ///   ]
  static Future<List<Map<dynamic, dynamic>>> near_rooms(
    double lat,
    double lng,
    int count,
    String dayOfWeek,
    String startHHMM,
    String endHHMM,
  ) async {
    Uri request = Uri.https(Constants.baseUrl, "/near_rooms", {
      'lat': lat.toString(),
      'lng': lng.toString(),
      'count': count.toString(),
      'day': dayOfWeek,
      'start': startHHMM,
      'end': endHHMM,
    });
    final response = await get(request);
    List<dynamic> json = jsonDecode(response.body)['rooms'];
    return [
      for (dynamic obj in json)
        {
          'name': obj['name'],
          'lat': obj['lat'],
          'lng': obj['lng'],
          'floor': obj['floor'],
          'occupied': obj['occupied'],
        },
    ];
  }

  static Future<void> contribute_route(
    List<String> nodes,
    List<int> timestamps,
  ) async {
    Uri request = Uri.https(Constants.baseUrl, "/contribute_route");
    await post(
      request,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: json.encode([
        for (int i = 0; i < nodes.length; i++)
          {'name': nodes[i].replaceAll(" ", "_ "), 'timestamp': timestamps[i]},
      ]),
    );
  }
}
