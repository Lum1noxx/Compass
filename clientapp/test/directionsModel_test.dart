import 'dart:async';
import 'dart:nativewrappers/_internal/vm/lib/math_patch.dart';

import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/main.dart';
import 'package:clientapp/models/compassModel.dart';
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
    CompassModel model = CompassModel();
    Destination dest = await model.getDest("COM3");
    expect(dest.name, "COM3");
  });
  test("queryAutocomplete", () {
    CompassModel model = CompassModel();
    List<String> res = model.queryAutocomplete("M3");
    expect(res.first, "COM3");
  });
  group("findPath and getNodesOnPath", () {
    test("first findPath, valid and no filters", () async {
      CompassModel model = CompassModel();
      Destination makers = await Globals.destinations.get("Makers@SoC");
      Destination pitstop = await Globals.destinations.get("PitStop@SoC");
      Path path = await model.findPath(
        makers,
        pitstop,
        FilterLevel.none,
        FilterLevel.none,
      );
      List<Edge> edges = path.edges;
      Node prev = edges.first.end;
      for (Edge edge in edges.sublist(1, edges.length)) {
        expect(edge.start, prev);
        prev = edge.end;
      }
    });
    test("second findPath, valid and no filters", () async {
      CompassModel model = CompassModel();
      Destination makers = await Globals.destinations.get("Makers@SoC");
      Destination pitstop = await Globals.destinations.get("PitStop@SoC");
      await model.findPath(makers, pitstop, FilterLevel.none, FilterLevel.none);
      Destination sr21 = await Globals.destinations.get("WS Lab 1");
      Path path = await model.findPath(
        makers,
        sr21,
        FilterLevel.none,
        FilterLevel.none,
      );
      List<Edge> edges = path.edges;
      Node prev = edges.first.end;
      for (Edge edge in edges.sublist(1, edges.length)) {
        expect(edge.start, prev);
        prev = edge.end;
      }
    });

    test("valid but longer, both filters", () async {
      CompassModel model = CompassModel();
      Destination makers = await Globals.destinations.get("Makers@SoC");
      Destination sr21 = await Globals.destinations.get("COM3 seminar room 21");
      Path filter = await model.findPath(
        makers,
        sr21,
        FilterLevel.strict,
        FilterLevel.strict,
      );
      List<Edge> edges = filter.edges;
      Node prev = edges.first.end;
      for (Edge edge in edges.sublist(1, edges.length)) {
        expect(edge.start, prev);
        prev = edge.end;
      }
      Path noFilter = await model.findPath(
        makers,
        sr21,
        FilterLevel.none,
        FilterLevel.none,
      );
      edges = noFilter.edges;
      prev = edges.first.end;
      for (Edge edge in edges.sublist(1, edges.length)) {
        expect(edge.start, prev);
        prev = edge.end;
      }
      assert(filter.duration > noFilter.duration);
      expect(filter.shelterFilterMet, true);
      expect(filter.stairFilterMet, true);
    });

    test('invalid, one destination contains the other', () async {
      CompassModel model = CompassModel();
      Destination makers = await Globals.destinations.get("Makers@SoC");
      Destination com3 = await Globals.destinations.get("COM3");
      Path filter = await model.findPath(
        makers,
        com3,
        FilterLevel.none,
        FilterLevel.none,
      );
      expect(filter is EdgelessPath, true);
    });

    test('invalid, destination does not exist', () async {
      CompassModel model = CompassModel();
      Destination makers = await Globals.destinations.get("Makers@SoC");
      Destination com5 = Destination("COM5", Coordinate(1, 100, 1));
      Path filter = await model.findPath(
        makers,
        com5,
        FilterLevel.none,
        FilterLevel.none,
      );
      expect(filter is ImpossiblePath, true);
    });
    test('invalid due to filter', () async {
      CompassModel model = CompassModel();
      Destination makers = await Globals.destinations.get("Makers@SoC");
      Destination pitstop = await Globals.destinations.get("PitStop@SoC");
      Path filter = await model.findPath(
        makers,
        pitstop,
        FilterLevel.strict,
        FilterLevel.strict,
      );
      expect(filter.isValid(), true);
      expect(filter.stairFilterMet, false);
      expect(filter.shelterFilterMet, true);
    });
    test('by coordinate, valid but longer with filters', () async {
      CompassModel model = CompassModel();
      TempDestination makers = TempDestination(
        Coordinate(1.2948950536, 103.7743995103, 1),
      ); // Makers@SoC
      Destination sr21 = await Globals.destinations.get("COM3 seminar room 21");
      Path filter = await model.findPath(
        makers,
        sr21,
        FilterLevel.strict,
        FilterLevel.strict,
      );
      List<Edge> edges = filter.edges;
      Node prev = edges.first.end;
      for (Edge edge in edges.sublist(1, edges.length)) {
        expect(edge.start, prev);
        prev = edge.end;
      }
      Path noFilter = await model.findPath(
        makers,
        sr21,
        FilterLevel.none,
        FilterLevel.none,
      );
      edges = noFilter.edges;
      prev = edges.first.end;
      for (Edge edge in edges.sublist(1, edges.length)) {
        expect(edge.start, prev);
        prev = edge.end;
      }
      assert(filter.duration > noFilter.duration);
      expect(filter.stairFilterMet, true);
      expect(filter.shelterFilterMet, true);
    });
    test('by coordinate, invalid due to filters', () async {
      CompassModel model = CompassModel();
      TempDestination makers = TempDestination(
        Coordinate(1.2948950536, 103.7743995103, 1),
      ); // Makers@SoC
      Destination pitstop = await Globals.destinations.get("PitStop@SoC");
      Path filter = await model.findPath(
        makers,
        pitstop,
        FilterLevel.strict,
        FilterLevel.strict,
      );
      expect(filter.isValid(), true);
      expect(filter.stairFilterMet, false);
      expect(filter.shelterFilterMet, true);
    });
  });
  test("getNearbyDestinations", () async {
    CompassModel model = CompassModel();
    TempDestination probe = TempDestination(
      Coordinate(1.2948950536, 103.7743995103, 1),
    );
    List<Destination> res = await model.getNearbyDestinations(probe);
    expect(res.length, Defaults.nearbyDestinationsCount);
    expect(res.first, await Globals.destinations.get("Makers@SoC"));
  });
  group("contribute route", () {
    test("handles invalid gps data without exception", () async {
      bool err = false;
      try {
        CompassModel model = CompassModel();
        Destination makers = await Globals.destinations.get("Makers@SoC");
        Destination pitstop = await Globals.destinations.get("PitStop@SoC");
        Path path = await model.findPath(
          makers,
          pitstop,
          FilterLevel.none,
          FilterLevel.none,
        );
        model.trackedPositions = [];
        model.submitTracking(path);
      } on Exception catch (e) {
        err = true;
      }
      expect(err, false);
    });
    test("handles valid gps data without exception", () async {
      bool err = false;
      try {
        CompassModel model = CompassModel();
        Destination makers = await Globals.destinations.get("Makers@SoC");
        Destination pitstop = await Globals.destinations.get("PitStop@SoC");
        Path path = await model.findPath(
          makers,
          pitstop,
          FilterLevel.none,
          FilterLevel.none,
        );
        int length = path.intermediateNodes().length;
        model.trackedPositions = [
          for (int i = 0; i < length; i++)
            TimedPosition(
              Coordinate(i + 0.0, i + 0.0, 1),
              DateTime.fromMillisecondsSinceEpoch(i * 10000),
            ),
        ];
        model.submitTracking(path);
      } on Exception catch (e) {
        err = true;
      }
      expect(err, false);
    });
  });
}
