import 'package:clientapp/data.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:test/test.dart';

void main() {
  group("coordinate", (){
    test("getLatLng", (){
      double lat = 1.23456789;
      double lng = 123.456789;
      int floor = -1;
      Coordinate coordinate = Coordinate(lat, lng, floor);
      expect(coordinate.getLatLng(), LatLng(lat, lng));
    });
  });
  group("nodes", (){
    test("node getLatLng", (){
      double lat = 1.23456789;
      double lng = 123.456789;
      int floor = -1;
      Coordinate coordinate = Coordinate(lat, lng, floor);
      Node node = Node("test node", coordinate);
      expect(node.getLatLng(), LatLng(lat, lng));
    });
    test("nodes fetch", () async{
      Nodes nodes = Nodes();
      expect(setEquals(Set.from(nodes.map.keys), {}) , true);
      await nodes.fetch(['d1', 'd2', 'd3']);
      expect(setEquals(Set.from(nodes.map.keys), {'d1', 'd2', 'd3'}) , true);
      await nodes.fetch(['d2', 'd3', 'd4']);
      expect(setEquals(Set.from(nodes.map.keys), {'d1', 'd2', 'd3', 'd4'}) , true);
      await nodes.get("d5");
      expect(Set.from(nodes.map.keys), {'d1', 'd2', 'd3', 'd4', 'd5'});
    });
  });
  group("destinations", (){
    test("destination getLatLng", (){
      double lat = 1.23456789;
      double lng = 123.456789;
      int floor = -1;
      Coordinate coordinate = Coordinate(lat, lng, floor);
      Destination destination = Destination("test destination", coordinate);
      expect(destination.getLatLng(), LatLng(lat, lng));
    });
    test("destinations autocomplete", () {
      Destinations destinations = Destinations([
        "abcd",
        "bcde",
        "cdef",
        "defg",
      ], 2);
      expect(destinations.autocomplete("a")[0], "abcd");
      expect(destinations.autocomplete("ab"), ["abcd", "bcde"]);
      expect(destinations.autocomplete("cde"), ["cdef", "bcde"]);
      expect(setEquals(Set.from(destinations.autocomplete("cde")), {"bcde", "cdef"}), true);

    });
    test("destinations fetch", () async{
      Destinations destinations = Destinations(['d1', 'd2', 'd3', 'd4', 'd5'], 2);
      expect(setEquals(Set.from(destinations.map.keys), {}), true);
      await destinations.fetch(['d1', 'd2', 'd3']);
      expect(setEquals(Set.from(destinations.map.keys), {'d1', 'd2', 'd3'}), true);
      await destinations.fetch(['d2', 'd3', 'd4']);
      expect(setEquals(Set.from(destinations.map.keys), {'d1', 'd2', 'd3', 'd4'}), true);
      await destinations.get("d5");
      expect(setEquals(Set.from(destinations.map.keys), {'d1', 'd2', 'd3', 'd4', 'd5'}), true);
    });
  });
  group("edges", (){
    test("EdgeType get", () {
      expect(EdgeType.get("walk"), EdgeType.walk);
      expect(EdgeType.get("waitForBus"), EdgeType.waitForBus);
    });
  });  
}