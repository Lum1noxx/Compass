import 'dart:async';

import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/main.dart';
import 'package:clientapp/models/directionsModel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart' hide Path;

void main() {
  Globals.destinations = Destinations([
    "COM3",
    "COM3 seminar room 21"
        'Makers@SoC',
    'PitStop@SoC',
  ], 2);
  Globals.nodes = Nodes();
  test("getDest", () async {
    DirectionsModel model = DirectionsModel();
    Destination dest = await model.getDest("COM3");
    expect(dest.name, "COM3");
  });
  test("queryAutocomplete", () {
    DirectionsModel model = DirectionsModel();
    List<String> res = model.queryAutocomplete("M3");
    expect(res.first, "COM3");
  });
  group("findPath and getNodesOnPath", () {
    test("first findPath, valid and no filters", () async {
      DirectionsModel model = DirectionsModel();
      Destination makers = await Globals.destinations.get("Makers@SoC");
      Destination pitstop = await Globals.destinations.get("PitStop@SoC");
      Path path = await model.findPath(makers, pitstop, false, false);
      List<Edge> edges = path.edges;
      Node prev = edges.first.end;
      for (Edge edge in edges.sublist(1, edges.length)) {
        expect(edge.start, prev);
        prev = edge.end;
      }
    });
    test("second findPath, valid and no filters", () async {
      DirectionsModel model = DirectionsModel();
      Destination makers = await Globals.destinations.get("Makers@SoC");
      Destination pitstop = await Globals.destinations.get("PitStop@SoC");
      await model.findPath(makers, pitstop, false, false);
      Destination sr21 = await Globals.destinations.get("WS Lab 1");
      Path path = await model.findPath(makers, sr21, false, false);
      List<Edge> edges = path.edges;
      Node prev = edges.first.end;
      for (Edge edge in edges.sublist(1, edges.length)) {
        expect(edge.start, prev);
        prev = edge.end;
      }
    });

    test("valid but longer, both filters", () async {
      DirectionsModel model = DirectionsModel();
      Destination makers = await Globals.destinations.get("Makers@SoC");
      Destination sr21 = await Globals.destinations.get("COM3 seminar room 21");
      Path filter = await model.findPath(makers, sr21, true, true);
      List<Edge> edges = filter.edges;
      Node prev = edges.first.end;
      for (Edge edge in edges.sublist(1, edges.length)) {
        expect(edge.start, prev);
        prev = edge.end;
      }
      Path noFilter = await model.findPath(makers, sr21, false, false);
      edges = noFilter.edges;
      prev = edges.first.end;
      for (Edge edge in edges.sublist(1, edges.length)) {
        expect(edge.start, prev);
        prev = edge.end;
      }
      assert(filter.duration > noFilter.duration);
    });

    test('invalid, one destination contains the other', () async {
      DirectionsModel model = DirectionsModel();
      Destination makers = await Globals.destinations.get("Makers@SoC");
      Destination com3 = await Globals.destinations.get("COM3");
      Path filter = await model.findPath(makers, com3, false, false);
      expect(filter is EdgelessPath, true);
    });

    test('invalid, destination does not exist', () async {
      DirectionsModel model = DirectionsModel();
      Destination makers = await Globals.destinations.get("Makers@SoC");
      Destination com5 = Destination("COM5", Coordinate(1, 100, 1));
      Path filter = await model.findPath(makers, com5, false, false);
      expect(filter is ImpossiblePath, true);
    });
    test('invalid due to filter', () async {
      DirectionsModel model = DirectionsModel();
      Destination makers = await Globals.destinations.get("Makers@SoC");
      Destination pitstop = await Globals.destinations.get("PitStop@SoC");
      Path filter = await model.findPath(makers, pitstop, true, true);
      expect(filter is ImpossiblePath, true);
    });
    test('by coordinate, valid but longer with filters', () async {
      DirectionsModel model = DirectionsModel();
      TempDestination makers = TempDestination(
        Coordinate(1.2948950536, 103.7743995103, 1),
      ); // Makers@SoC
      Destination sr21 = await Globals.destinations.get("COM3 seminar room 21");
      Path filter = await model.findPath(makers, sr21, true, true);
      List<Edge> edges = filter.edges;
      Node prev = edges.first.end;
      for (Edge edge in edges.sublist(1, edges.length)) {
        expect(edge.start, prev);
        prev = edge.end;
      }
      Path noFilter = await model.findPath(makers, sr21, false, false);
      edges = noFilter.edges;
      prev = edges.first.end;
      for (Edge edge in edges.sublist(1, edges.length)) {
        expect(edge.start, prev);
        prev = edge.end;
      }
      assert(filter.duration > noFilter.duration);
    });
    test('by coordinate, invalid due to filters', () async {
      DirectionsModel model = DirectionsModel();
      TempDestination makers = TempDestination(
        Coordinate(1.2948950536, 103.7743995103, 1),
      ); // Makers@SoC
      Destination pitstop = await Globals.destinations.get("PitStop@SoC");
      Path filter = await model.findPath(makers, pitstop, true, true);
      expect(filter is ImpossiblePath, true);
    });
  });
  test("getNearbyDestinations", () async {
    DirectionsModel model = DirectionsModel();
    TempDestination probe = TempDestination(
      Coordinate(1.2948950536, 103.7743995103, 1),
    );
    List<Destination> res = await model.getNearbyDestinations(probe);
    expect(res.length, Defaults.nearbyDestinationsCount);
    expect(res.first, await Globals.destinations.get("Makers@SoC"));
  });
}
