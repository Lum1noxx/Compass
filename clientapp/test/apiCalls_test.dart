import 'package:clientapp/apiCalls.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("shortest_path", () async {
    List<Map> res = await ApiCalls.shortest_path('com3', 'com4');
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

  test("node_coordinates", () async {
    List<Map> res = await ApiCalls.node_coordinates(['com4 linkway entrance', 'com3 north corridor']);
    expect(
      {
        for (Map obj in res)
          obj['name']
      }, {'com4 linkway entrance', 'com3 north corridor'}
    );
    expect(res.first['lat'] is num, true);
    expect(res.first['lng'] is num, true);
    expect(res.first['floor'] is int, true);
  });

    test("dest_coordinates", () async {
    List<Map> res = await ApiCalls.node_coordinates(['com4', 'com3']);
    expect(
      {
        for (Map obj in res)
          obj['name']
      }, {'com4', 'com3'}
    );
    expect(res.first['lat'] is num, true);
    expect(res.first['lng'] is num, true);
    expect(res.first['floor'] is int, true);
  });
}