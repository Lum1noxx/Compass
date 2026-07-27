import 'dart:math';

import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/main.dart';
import 'package:clientapp/models/compassModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart' hide Path;

void main() {
  Globals.destinations = Destinations([
    "COM3",
    "COM3 seminar room 21",
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
      // expect(filter.shelterFilterMet, true);
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
      // expect(filter.shelterFilterMet, true);
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
    test("fits tracking data optimally", () {
      CompassModel model = CompassModel();
      Destination start = Destination("start", Coordinate(0, 0, 0));
      Destination end = Destination("end", Coordinate(1, 1, 2));
      Node w1 = Node("w1", Coordinate(0, 0.1, 0));
      Node w2 = Node("w2", Coordinate(0.1, 0.1, 0));
      Node wb1 = Node("wb1", Coordinate(0.1, 0.1, 0));
      Node b1 = Node("b1", Coordinate(0.2, 0.1, 0));
      Node b2 = Node("b2", Coordinate(0.2, 0.2, 0));
      Node w3 = Node("w3", Coordinate(0.2, 0.3, 0));
      Path path = Path.autoJoin(
        [
          Edge(EdgeType.walk, w1, w2, true, false, 1),
          WaitForBusEdge(EdgeType.waitForBus, w2, wb1, true, false, 1, [
            "D1",
            "D2",
            "D3",
          ]),
          Edge(EdgeType.bus, wb1, b1, true, false, 1),
          Edge(EdgeType.bus, b1, b2, true, false, 1),
          Edge(EdgeType.walk, b2, w3, true, false, 1),
        ],
        start,
        end,
        true,
        true,
      );
      List<TimedPosition> tracked = [
        TimedPosition(
          Coordinate(-0.01, 0.11, 0),
          DateTime.fromMillisecondsSinceEpoch(0),
        ), //hit
        TimedPosition(
          Coordinate(-0.02, 0.11, 0),
          DateTime.fromMillisecondsSinceEpoch(1),
        ), //miss:far
        TimedPosition(
          Coordinate(0.09, 0.11, 0),
          DateTime.fromMillisecondsSinceEpoch(2),
        ), //hit
        TimedPosition(
          Coordinate(0.2, 0.3, 0),
          DateTime.fromMillisecondsSinceEpoch(3),
        ), //miss:order
        TimedPosition(
          Coordinate(0.09, 0.12, 0),
          DateTime.fromMillisecondsSinceEpoch(4),
        ), //miss:far
        TimedPosition(
          Coordinate(0.09, 0.11, 0),
          DateTime.fromMillisecondsSinceEpoch(5),
        ), //hit
        TimedPosition(
          Coordinate(0.21, 0.11, 0),
          DateTime.fromMillisecondsSinceEpoch(6),
        ), //hit
        TimedPosition(
          Coordinate(0.21, 0.08, 0),
          DateTime.fromMillisecondsSinceEpoch(7),
        ), //miss:far
        TimedPosition(
          Coordinate(0.21, 0.19, 0),
          DateTime.fromMillisecondsSinceEpoch(8),
        ), //hit
        TimedPosition(
          Coordinate(0, 0.1, 0),
          DateTime.fromMillisecondsSinceEpoch(9),
        ), //miss:order
        TimedPosition(
          Coordinate(0.21, 0.18, 0),
          DateTime.fromMillisecondsSinceEpoch(10),
        ), //miss:far
        TimedPosition(
          Coordinate(0.21, 0.31, 0),
          DateTime.fromMillisecondsSinceEpoch(11),
        ), //hit
        TimedPosition(
          Coordinate(0.21, 0.28, 0),
          DateTime.fromMillisecondsSinceEpoch(12),
        ), //miss:far
      ];
      List<TimedPosition> fitted = model.fitTrackingData(path, tracked);
      expect(fitted.length, 6);
      expect(fitted[0], tracked[0]);
      expect(fitted[1], tracked[2]);
      expect(fitted[2], tracked[5]);
      expect(fitted[3], tracked[6]);
      expect(fitted[4], tracked[8]);
      expect(fitted[5], tracked[11]);
    });
  });
  group("getVacantVenues", () {
    TempDestination com4 = TempDestination.plane(
      LatLng(1.2951646095, 103.7753551262),
    );
    TempDestination utown = TempDestination.plane(
      LatLng(1.3053703381, 103.7734655973),
    );
    test("correct number of venues returned", () async {
      CompassModel model = CompassModel();
      List<Venue> venues = await model.getVacantVenues(
        com4,
        0,
        Period(TimeOfDay(hour: 10, minute: 5), TimeOfDay(hour: 12, minute: 20)),
      );
      expect(venues.length, Defaults.nearbyVenuesCount);
    });
    test("valid vacancies", () async {
      CompassModel model = CompassModel();
      List<Venue> venues = await model.getVacantVenues(
        com4,
        0,
        Period(TimeOfDay(hour: 10, minute: 5), TimeOfDay(hour: 12, minute: 20)),
      );
      List<Venue> venues2 = await model.getVacantVenues(
        utown,
        0,
        Period(TimeOfDay(hour: 15, minute: 5), TimeOfDay(hour: 17, minute: 20)),
      );
      for (Venue venue in venues) {
        expect(venue.isVacantAt(TimeOfDay(hour: 10, minute: 6)), true);
        expect(venue.isVacantAt(TimeOfDay(hour: 11, minute: 30)), true);
        expect(venue.isVacantAt(TimeOfDay(hour: 12, minute: 19)), true);
      }
      for (Venue venue in venues2) {
        expect(venue.isVacantAt(TimeOfDay(hour: 15, minute: 6)), true);
        expect(venue.isVacantAt(TimeOfDay(hour: 16, minute: 30)), true);
        expect(venue.isVacantAt(TimeOfDay(hour: 17, minute: 19)), true);
      }
    });
    test("returns nearest possible", () async {
      CompassModel model = CompassModel();
      List<Venue> venuesc = await model.getVacantVenues(
        com4,
        0,
        Period(TimeOfDay(hour: 10, minute: 5), TimeOfDay(hour: 12, minute: 20)),
      );
      List<Venue> venuesu = await model.getVacantVenues(
        utown,
        0,
        Period(TimeOfDay(hour: 10, minute: 5), TimeOfDay(hour: 12, minute: 20)),
      );
      Set<Venue> venuesa = Set.from(venuesc);
      venuesa.addAll(venuesu);
      print(List.from(venuesa.map((venue)=>venue.name)));
      double maxDistC = venuesc.fold(
        0,
        (accum, nxt) =>
            max(accum, Haversine().distance(nxt.getLatLng(), com4.getLatLng())),
      );
      double maxDistU = venuesu.fold(
        0,
        (accum, nxt) => max(
          accum,
          Haversine().distance(nxt.getLatLng(), utown.getLatLng()),
        ),
      );
      double minDistLessC = venuesa
          .difference(Set.from(venuesc))
          .fold(
            double.infinity,
            (accum, nxt) => min(
              accum,
              Haversine().distance(nxt.getLatLng(), com4.getLatLng()),
            ),
          );
      double minDistLessU = venuesa
          .difference(Set.from(venuesu))
          .fold(
            double.infinity,
            (accum, nxt) => min(
              accum,
              Haversine().distance(nxt.getLatLng(), utown.getLatLng()),
            ),
          );
      expect(maxDistU <= minDistLessU || minDistLessU == double.infinity, true);
      expect(maxDistC <= minDistLessC || minDistLessC == double.infinity, true);
    });
  });
}
