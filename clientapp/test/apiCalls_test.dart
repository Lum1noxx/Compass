import 'package:clientapp/UserExceptions.dart';
import 'package:clientapp/apiCalls.dart';
import 'package:clientapp/data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group("shortest_path", () {
    test("valid, no filters", () async {
      Map res = await ApiCalls.shortest_path(
        'COM3',
        'COM4',
        FilterLevel.none,
        FilterLevel.none,
      );
      List edges = res['edges'];
      expect(edges.first.containsKey('start'), true);
      expect(edges.first.containsKey('type'), true);
      expect(edges.first.containsKey('end'), true);
      expect(edges.first['sheltered'] is bool, true);
      expect(edges.first['stairs'] is bool, true);
      expect(edges.first['duration'] is num, true);
      String prev = edges.first['end'];
      for (Map edge in edges.sublist(1, edges.length)) {
        expect(edge['start'], prev);
        prev = edge['end'];
      }
    });
    test("valid and same, both filters", () async {
      Map raw = await ApiCalls.shortest_path(
        'COM3',
        'COM4',
        FilterLevel.strict,
        FilterLevel.strict,
      );
      List edges = raw['edges'];
      expect(edges.first.containsKey('type'), true);
      expect(edges.first.containsKey('start'), true);
      expect(edges.first.containsKey('end'), true);
      expect(edges.first['sheltered'] is bool, true);
      expect(edges.first['stairs'] is bool, true);
      expect(edges.first['duration'] is num, true);
      String prev = edges.first['end'];
      for (Map edge in edges.sublist(1, edges.length)) {
        expect(edge['start'], prev);
        expect(edge['stairs'], false);
        expect(edge['sheltered'], true);
        prev = edge['end'];
      }
      Map res2 = await ApiCalls.shortest_path(
        'COM3',
        'COM4',
        FilterLevel.none,
        FilterLevel.none,
      );
      expect(edges, res2['edges']);
      expect(FilterLevel.get(raw['stairsPref']), FilterLevel.strict);
      expect(FilterLevel.get(raw['shelterPref']), FilterLevel.strict);
    });
    test("valid but longer, both filters", () async {
      Map res = await ApiCalls.shortest_path(
        'Makers@SoC',
        'COM3_seminar_room_21',
        FilterLevel.strict,
        FilterLevel.strict,
      );
      List edges = res['edges'];
      expect(edges.first.containsKey('type'), true);
      expect(edges.first.containsKey('start'), true);
      expect(edges.first.containsKey('end'), true);
      expect(edges.first['sheltered'] is bool, true);
      expect(edges.first['stairs'] is bool, true);
      expect(edges.first['duration'] is num, true);
      String prev = edges.first['end'];
      for (Map edge in edges.sublist(1, edges.length)) {
        expect(edge['start'], prev);
        expect(edge['stairs'], false);
        expect(edge['sheltered'], true);
        prev = edge['end'];
      }
      Map res2 = await ApiCalls.shortest_path(
        'Makers@SoC',
        'COM3_seminar_room_21',
        FilterLevel.none,
        FilterLevel.none,
      );
      List edges2 = res2['edges'];
      num filterSum = 0;
      num noFilterSum = 0;
      for (Map edge in edges) {
        filterSum += edge['duration'];
      }
      for (Map edge in edges2) {
        noFilterSum += edge['duration'];
      }
      expect(filterSum > noFilterSum, true);
      expect(FilterLevel.get(res['stairsPref']), FilterLevel.strict);
      expect(FilterLevel.get(res['shelterPref']), FilterLevel.strict);
    });
    test("invalid, one destination contains the other", () async {
      bool err = false;
      try {
        Map res = await ApiCalls.shortest_path(
          'COM4',
          'COM4 L2',
          FilterLevel.none,
          FilterLevel.none,
        );
      } on EdgelessPathException {
        err = true;
      }
      expect(err, true);
    });
    test("invalid, destination does not exist", () async {
      bool err = false;
      try {
        Map res = await ApiCalls.shortest_path(
          'COM3',
          'COM5',
          FilterLevel.none,
          FilterLevel.none,
        );
      } on ImpossiblePathException {
        err = true;
      }
      expect(err, true);
    });
    test("impossible due to filters", () async {
      Map res = await ApiCalls.shortest_path(
        'Makers@SoC',
        'PitStop@SoC',
        FilterLevel.strict,
        FilterLevel.strict,
      );
      List edges = res['edges'];
      expect(edges.first.containsKey('type'), true);
      expect(edges.first.containsKey('start'), true);
      expect(edges.first.containsKey('end'), true);
      expect(edges.first['sheltered'] is bool, true);
      expect(edges.first['stairs'] is bool, true);
      expect(edges.first['duration'] is num, true);
      String prev = edges.first['end'];
      for (Map edge in edges.sublist(1, edges.length)) {
        expect(edge['start'], prev);
        prev = edge['end'];
      }

      expect(FilterLevel.get(res['stairsPref']), FilterLevel.prefer);
      // expect(FilterLevel.get(res['shelterPref']), FilterLevel.strict);
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
      Map res = (await ApiCalls.use_location(
        1.2948950536,
        103.7743995103,
        1,
        'COM3_seminar_room_21',
        FilterLevel.strict,
        FilterLevel.strict,
      ));
      List edges = res['edges'].sublist(1);
      expect(edges.first.containsKey('type'), true);
      expect(edges.first.containsKey('start'), true);
      expect(edges.first.containsKey('end'), true);
      expect(edges.first['sheltered'] is bool, true);
      expect(edges.first['stairs'] is bool, true);
      expect(edges.first['duration'] is num, true);
      String prev = edges.first['end'];
      for (Map edge in edges.sublist(1, edges.length)) {
        expect(edge['start'], prev);
        expect(edge['stairs'], false);
        expect(edge['sheltered'], true);
        prev = edge['end'];
      }
      Map res2 = (await ApiCalls.use_location(
        1.2948950536,
        103.7743995103,
        1,
        'COM3_seminar_room_21',
        FilterLevel.none,
        FilterLevel.none,
      ));
      List edges2 = res2['edges'].sublist(1);
      num filterSum = 0;
      num noFilterSum = 0;
      for (Map edge in edges) {
        filterSum += edge['duration'];
      }
      for (Map edge in edges2) {
        noFilterSum += edge['duration'];
      }
      expect(filterSum > noFilterSum, true);
      expect(FilterLevel.get(res['stairsPref']), FilterLevel.strict);
      expect(FilterLevel.get(res['shelterPref']), FilterLevel.strict);
    });
    test("invalid, destination does not exist", () async {
      bool err = false;
      try {
        Map res = (await ApiCalls.use_location(
          1.2948950536,
          103.7743995103,
          1,
          'COM5',
          FilterLevel.none,
          FilterLevel.none,
        ));
      } on ImpossiblePathException {
        err = true;
      }
      expect(err, true);
    });
    test("impossible due to filter", () async {
      bool err = false;
      Map res = (await ApiCalls.use_location(
        1.2948950536,
        103.7743995103,
        1,
        'PitStop@SoC',
        FilterLevel.strict,
        FilterLevel.strict,
      ));
      List edges = res['edges'].sublist(1);
      expect(edges.first.containsKey('type'), true);
      expect(edges.first.containsKey('start'), true);
      expect(edges.first.containsKey('end'), true);
      expect(edges.first['sheltered'] is bool, true);
      expect(edges.first['stairs'] is bool, true);
      expect(edges.first['duration'] is num, true);
      String prev = edges.first['end'];
      for (Map edge in edges.sublist(1, edges.length)) {
        expect(edge['start'], prev);
        prev = edge['end'];
      }

      /// NOT MY FAULT
      expect(FilterLevel.get(res['stairsPref']), FilterLevel.prefer);
      // expect(FilterLevel.get(res['shelterPref']), FilterLevel.strict);
    });

    test("invalid, destination does not exist", () async {
      bool err = false;
      try {
        Map res = await ApiCalls.use_location(
          1.2948950536,
          103.7743995103,
          1,
          'COM5',
          FilterLevel.none,
          FilterLevel.none,
        );
      } on ImpossiblePathException {
        err = true;
      }
      expect(err, true);
    });
  });

  group("contribute_route", () {
    test("data submitted without exception", () async {
      bool err = false;
      try {
        ApiCalls.contribute_route(
          [
            'com1 b1 north stairwell',
            'com1 b1 main corridor north end',
            'com1 b1 main corridor south branch',
          ],
          [111, 222, 333],
        );
      } catch (e) {
        err = true;
      }
      ;
      expect(err, false);
    });
    group("near_rooms", () {
      LatLng com4 = LatLng(1.2951646095, 103.7753551262);
      test("correct return schema", () async {
        List<Map> res = await ApiCalls.near_rooms(
          com4.latitude,
          com4.longitude,
          3,
          "Monday",
          '1005',
          '1410',
        );
        expect(res.isNotEmpty, true);
        Map item = res.first;
        expect(item['name'] is String, true);
        expect(item['lat'] is double, true);
        expect(item['lng'] is double, true);
        expect(item['floor'] is int, true);
        expect(item["occupied"] is List, true);
      });
      test("correct number of venues", () async {
        List<Map> res = await ApiCalls.near_rooms(
          com4.latitude,
          com4.longitude,
          4,
          "Monday",
          '1005',
          '1410',
        );
        expect(res.length, 4);
      });
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
