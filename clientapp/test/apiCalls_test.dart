import 'dart:math';

import 'package:clientapp/UserExceptions.dart';
import 'package:clientapp/apiCalls.dart';
import 'package:clientapp/data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("shortest_path", () {
    test("valid, no filters", () async {
      List<Map> res = await ApiCalls.shortest_path(
        'COM3',
        'COM4',
        false,
        false,
      );
      expect(res.first.containsKey('type'), true);
      expect(res.first.containsKey('start'), true);
      expect(res.first.containsKey('end'), true);
      expect(res.first['sheltered'] is bool, true);
      expect(res.first['stairs'] is bool, true);
      expect(res.first['duration'] is num, true);
      String prev = res.first['end'];
      for (Map edge in res.sublist(1, res.length)) {
        expect(edge['start'], prev);
        prev = edge['end'];
      }
    });
    test("valid and same, both filters", () async {
      List<Map> res = await ApiCalls.shortest_path('COM3', 'COM4', true, true);
      expect(res.first.containsKey('type'), true);
      expect(res.first.containsKey('start'), true);
      expect(res.first.containsKey('end'), true);
      expect(res.first['sheltered'] is bool, true);
      expect(res.first['stairs'] is bool, true);
      expect(res.first['duration'] is num, true);
      String prev = res.first['end'];
      for (Map edge in res.sublist(1, res.length)) {
        expect(edge['start'], prev);
        expect(edge['stairs'], false);
        expect(edge['sheltered'], true);
        prev = edge['end'];
      }
      List<Map> res2 = await ApiCalls.shortest_path(
        'COM3',
        'COM4',
        false,
        false,
      );
      expect(res, res2);
    });
    test("valid but longer, both filters", () async {
      List<Map> res = await ApiCalls.shortest_path(
        'Makers@SoC',
        'COM3_seminar_room_21',
        true,
        true,
      );
      expect(res.first.containsKey('type'), true);
      expect(res.first.containsKey('start'), true);
      expect(res.first.containsKey('end'), true);
      expect(res.first['sheltered'] is bool, true);
      expect(res.first['stairs'] is bool, true);
      expect(res.first['duration'] is num, true);
      String prev = res.first['end'];
      for (Map edge in res.sublist(1, res.length)) {
        expect(edge['start'], prev);
        expect(edge['stairs'], false);
        expect(edge['sheltered'], true);
        prev = edge['end'];
      }
      List<Map> res2 = await ApiCalls.shortest_path(
        'Makers@SoC',
        'COM3_seminar_room_21',
        false,
        false,
      );
      num filterSum = 0;
      num noFilterSum = 0;
      for (Map edge in res) {
        filterSum += edge['duration'];
      }
      for (Map edge in res2) {
        noFilterSum += edge['duration'];
      }
      expect(filterSum > noFilterSum, true);
    });
    test("invalid, one destination contains the other", () async {
      bool err = false;
      try {
        List<Map> res = await ApiCalls.shortest_path(
          'COM4',
          'COM4 L2',
          false,
          false,
        );
      } on EdgelessPathException {
        err = true;
      }
      expect(err, true);
    });
    test("invalid, destination does not exist", () async {
      bool err = false;
      try {
        List<Map> res = await ApiCalls.shortest_path(
          'COM3',
          'COM5',
          false,
          false,
        );
      } on ImpossiblePathException {
        err = true;
      }
      expect(err, true);
    });
    test("impossible due to filters", () async {
      bool err = false;
      try {
        List<Map> res = await ApiCalls.shortest_path(
          'Makers@SoC',
          'PitStop@SoC',
          true,
          true,
        );
      } on ImpossiblePathException {
        err = true;
      }
      expect(err, true);
      List<Map> res = await ApiCalls.shortest_path(
        'Makers@SoC',
        'PitStop@SoC',
        false,
        false,
      );
      expect(res.first.containsKey('type'), true);
      expect(res.first.containsKey('start'), true);
      expect(res.first.containsKey('end'), true);
      expect(res.first['sheltered'] is bool, true);
      expect(res.first['stairs'] is bool, true);
      expect(res.first['duration'] is num, true);
      String prev = res.first['end'];
      for (Map edge in res.sublist(1, res.length)) {
        expect(edge['start'], prev);
        prev = edge['end'];
      }
    });
  });

  test("node_coordinates", () async {
    List<Map> res = await ApiCalls.node_coordinates([
      'com3 north lift (l1)',
      'com4 l2 classrooms',
    ]);
    expect(
      {for (Map obj in res) obj['name']},
      {'com3 north lift (l1)', 'com4 l2 classrooms'},
    );
    expect(res.first['lat'] is num, true);
    expect(res.first['lng'] is num, true);
    expect(res.first['floor'] is int, true);
  });

  test("dest_coordinates", () async {
    List<Map> res = await ApiCalls.dest_coordinates(['COM3', 'COM4']);
    expect({for (Map obj in res) obj['name']}, {'COM3', 'COM4'});
    expect(res.first['lat'] is num, true);
    expect(res.first['lng'] is num, true);
    expect(res.first['floor'] is int, true);
  });

  test("near_destinations", () async {
    List<Map> res = await ApiCalls.near_destinations(1.29488, 103.775, 1, 3);
    expect(res.length, 3);
    Map nearest = res.first;
    res = await ApiCalls.near_destinations(1.29488, 103.775, 1, 1);
    expect(res.length, 1);
    expect(res.first, nearest);
    expect(res.first['name'] is String, true);
    expect(res.first['lat'] is num, true);
    expect(res.first['lng'] is num, true);
    expect(res.first['floor'] is int, true);
  });

  group("use_location", () {
    test("valid but longer, both filters", () async {
      List<Map> res = (await ApiCalls.use_location(
        1.2948950536,
        103.7743995103,
        1,
        'COM3_seminar_room_21',
        true,
        true,
      )).sublist(1);
      expect(res.first.containsKey('type'), true);
      expect(res.first.containsKey('start'), true);
      expect(res.first.containsKey('end'), true);
      expect(res.first['sheltered'] is bool, true);
      expect(res.first['stairs'] is bool, true);
      expect(res.first['duration'] is num, true);
      String prev = res.first['end'];
      for (Map edge in res.sublist(1, res.length)) {
        expect(edge['start'], prev);
        expect(edge['stairs'], false);
        expect(edge['sheltered'], true);
        prev = edge['end'];
      }
      List<Map> res2 = (await ApiCalls.use_location(
        1.2948950536,
        103.7743995103,
        1,
        'COM3_seminar_room_21',
        false,
        false,
      )).sublist(1);
      num filterSum = 0;
      num noFilterSum = 0;
      for (Map edge in res) {
        filterSum += edge['duration'];
      }
      for (Map edge in res2) {
        noFilterSum += edge['duration'];
      }
      expect(filterSum > noFilterSum, true);
    });
    test("invalid, destination does not exist", () async {
      bool err = false;
      try {
        List<Map> res = (await ApiCalls.use_location(
          1.2948950536,
          103.7743995103,
          1,
          'COM5',
          false,
          false,
        )).sublist(1);
      } on ImpossiblePathException {
        err = true;
      }
      expect(err, true);
    });
    test("impossible due to filter", () async {
      bool err = false;
      try {
        List<Map> res = (await ApiCalls.use_location(
          1.2948950536,
          103.7743995103,
          1,
          'PitStop@SoC',
          true,
          true,
        )).sublist(1);
      } on ImpossiblePathException {
        err = true;
      }
      expect(err, true);
      List<Map> res = await ApiCalls.use_location(
        1.2948950536,
        103.7743995103,
        1,
        'PitStop@SoC',
        false,
        false,
      );
      expect(res.first.containsKey('type'), true);
      expect(res.first.containsKey('start'), true);
      expect(res.first.containsKey('end'), true);
      expect(res.first['sheltered'] is bool, true);
      expect(res.first['stairs'] is bool, true);
      expect(res.first['duration'] is num, true);
      String prev = res.first['end'];
      for (Map edge in res.sublist(1, res.length)) {
        expect(edge['start'], prev);
        prev = edge['end'];
      }
    });
  
    test("invalid, destination does not exist", () async {
      bool err = false;
      try {
        List<Map> res = await ApiCalls.use_location(
          1.2948950536,
          103.7743995103,
          1,
          'COM5',
          false,
          false,
        );
      } on ImpossiblePathException {
        err = true;
      }
      expect(err, true);
    });
  });

  /// invalid shortest_path [x]
  ///   - Edgeless [x]
  ///   - dest DNE [x]
  /// TODO: find_path with filter [x]
  ///   - impossible [x]
  ///   - possible and same [x]
  ///   - possible but longer [x]
  /// TODO: get_near_destinations [x]
  /// TODO: use_current_location [x]
}
