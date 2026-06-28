import 'package:clientapp/data.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:test/test.dart';

void main() {
  group("coordinate", () {
    test("getLatLng", () {
      double lat = 1.23456789;
      double lng = 123.456789;
      int floor = -1;
      Coordinate coordinate = Coordinate(lat, lng, floor);
      expect(coordinate.getLatLng(), LatLng(lat, lng));
    });
  });
  group("nodes", () {
    test("node getLatLng", () {
      double lat = 1.23456789;
      double lng = 123.456789;
      int floor = -1;
      Coordinate coordinate = Coordinate(lat, lng, floor);
      Node node = Node("test node", coordinate);
      expect(node.getLatLng(), LatLng(lat, lng));
    });
    test("nodes fetch", () async {
      Nodes nodes = Nodes();
      expect(setEquals(Set.from(nodes.map.keys), {}), true);
      await nodes.fetch([
        "com4 linkway entrance",
        "com4 l2 toilet branch",
        "com4 l2 lobby branch",
      ]);
      Node lwe = await nodes.get("com4 linkway entrance");
      expect(
        setEquals(Set.from(nodes.map.keys), {
          "com4 linkway entrance",
          "com4 l2 toilet branch",
          "com4 l2 lobby branch",
        }),
        true,
      );
      await nodes.fetch([
        "com4 l2 toilet branch",
        "com4 l2 lobby branch",
        "com4 l2 classrooms branch",
      ]);
      expect(
        setEquals(Set.from(nodes.map.keys), {
          "com4 linkway entrance",
          "com4 l2 toilet branch",
          "com4 l2 lobby branch",
          "com4 l2 classrooms branch",
        }),
        true,
      );
      await nodes.get("com4 l2 classrooms");
      expect(Set.from(nodes.map.keys), {
        "com4 linkway entrance",
        "com4 l2 toilet branch",
        "com4 l2 lobby branch",
        "com4 l2 classrooms branch",
        "com4 l2 classrooms",
      });
      expect(await nodes.get("com4 linkway entrance"), lwe);
    });
  });
  group("destinations", () {
    test("destination getLatLng", () {
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
      expect(
        setEquals(Set.from(destinations.autocomplete("cde")), {"bcde", "cdef"}),
        true,
      );
    });
    test("destinations fetch", () async {
      Destinations destinations = Destinations([
        "ISA T-Lab 1",
        "ISA T-Lab 2",
        "COM3 SR15 (south door)",
        "WS Lab 1",
        "WS Lab 3",
      ], 2);
      expect(setEquals(Set.from(destinations.map.keys), {}), true);
      await destinations.fetch([
        "ISA T-Lab 1",
        "ISA T-Lab 2",
        "COM3 SR15 (south door)",
      ]);
      Destination tlab1 = await destinations.get("ISA T-Lab 1");
      expect(
        setEquals(Set.from(destinations.map.keys), {
          "ISA T-Lab 1",
          "ISA T-Lab 2",
          "COM3 SR15 (south door)",
        }),
        true,
      );
      await destinations.fetch([
        "ISA T-Lab 2",
        "COM3 SR15 (south door)",
        "WS Lab 1",
      ]);
      expect(
        setEquals(Set.from(destinations.map.keys), {
          "ISA T-Lab 1",
          "ISA T-Lab 2",
          "COM3 SR15 (south door)",
          "WS Lab 1",
        }),
        true,
      );
      await destinations.get("WS Lab 3");
      expect(
        setEquals(Set.from(destinations.map.keys), {
          "ISA T-Lab 1",
          "ISA T-Lab 2",
          "COM3 SR15 (south door)",
          "WS Lab 1",
          "WS Lab 3",
        }),
        true,
      );
      expect(await destinations.get("ISA T-Lab 1"), tlab1);
    });
  });
  group("edges", () {
    test("EdgeType get", () {
      expect(EdgeType.get("walk"), EdgeType.walk);
      expect(EdgeType.get("waitForBus"), EdgeType.waitForBus);
    });
  });

  test("path", () {
    Destination start = Destination("start", Coordinate(0, 0, 0));
    Destination end = Destination("end", Coordinate(1, 1, 2));
    Node w1 = Node("w1", Coordinate(0, 0.1, 0));
    Node w2 = Node("w2", Coordinate(0.1, 0.1, 0));
    Node wb1 = Node("wb1", Coordinate(0.1, 0.1, 0));
    Node b1 = Node("b1", Coordinate(0.2, 0.1, 0));
    Node b2 = Node("b2", Coordinate(0.2, 0.2, 0));
    Node w3 = Node("w3", Coordinate(0.2, 0.3, 0));
    Node wl1 = Node("wl1", Coordinate(0.2, 0.3, 0));
    Node l1 = Node("l1", Coordinate(0.3, 0.3, 1));
    Node l2 = Node("l1", Coordinate(0.3, 0.3, 2));
    Node w4 = Node("w4", Coordinate(0.4, 0.3, 2));
    Path path = Path.autoJoin(
      [
        Edge(EdgeType.walk, w1, w2, true, false, 1),
        Edge(EdgeType.waitForBus, w2, wb1, true, false, 1),
        Edge(EdgeType.bus, wb1, b1, true, false, 1),
        Edge(EdgeType.bus, b1, b2, true, false, 1),
        Edge(EdgeType.walk, b2, w3, true, false, 1),
        Edge(EdgeType.waitForLift, w3, wl1, true, false, 1),
        Edge(EdgeType.lift, wl1, l1, true, false, 1),
        Edge(EdgeType.lift, l1, l2, true, false, 1),
        Edge(EdgeType.walk, l2, w4, true, false, 1),
      ],
      start,
      end,
    );
    expect(path.length(), 11);
    expect(
      [for (Segment segment in path.segments) segment.edgeType()],
      [
        EdgeType.walk,
        EdgeType.bus,
        EdgeType.walk,
        EdgeType.lift,
        EdgeType.walk,
      ],
    );
    expect(path.start(), start);
    expect(path.end(), end);
    double innerDuration = 0;
    double innerLength = 0;
    for (Segment segment in path.segments) {
      for (Edge edge in segment.edges) {
        expect(edge.edgeType.isRelatedTo(segment.edgeType()), true);
      }
      innerLength += segment.edges.length;
      innerDuration += segment.duration;
    }
    double outerDuration = 0;
    for (Edge edge in path.edges) {
      outerDuration += edge.duration;
    }
    expect(path.duration, outerDuration);
    expect(path.duration, innerDuration);
    expect(path.length(), innerLength);
    expect(path.locate(wb1), path.segments[1]);
    expect(path.locate(b1), path.segments[1]);
    expect(path.locate(end), path.segments[4]);
    expect(path.locate(path.edges[8]), path.segments[3]);
    expect(path.locate(path.edges[6]), path.segments[3]);
  });
}
