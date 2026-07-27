import 'dart:async';
import 'dart:math';
import 'package:clientapp/UserExceptions.dart';
import 'package:clientapp/apiCalls.dart';
import 'package:clientapp/constants.dart';
import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/main.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' hide Path;

/// main model for app
///
/// coordinates core logic for all app features:
/// 1. Find nearby destinations
/// 2. GPS location
/// 3. search for destinations using autocomplete
/// 4. find best route between destinations and/or coordinates
class CompassModel {
  List<TimedPosition> trackedPositions = [];
  StreamSubscription? trackingStream;

  /// initialise a live GPS position stream with a callback
  ///
  /// Args:
  /// - callback: callback which triggers whenever a new GPS position is streamed
  ///
  /// Returns:
  /// - newly-created stream of GPS positions
  Future<StreamSubscription> streamGPS(void Function(LatLng) callback) async {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: Defaults.gpsUpdateThreshold,
    );
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    StreamSubscription<Position> stream =
        Geolocator.getPositionStream(
          locationSettings: locationSettings,
        ).listen((Position? position) {
          if (position != null) {
            callback.call(LatLng(position.latitude, position.longitude));
            /// ADD BEFORE FLIGHT
            // callback.call(LatLng(1.29445088, 103.7744729)); /// REMOVE BEFORE FLIGHT
          }
        });
    return stream;
  }

  /// retrieve the [Destination] with the given name
  ///
  /// Args:
  /// - destName: name of destination
  ///
  /// Returns:
  /// - [Destination] with the given name
  Future<Destination> getDest(String destName) async {
    return Globals.destinations.get(destName);
  }

  /// retrieve autocomplete suggestions for a partial destination name input
  ///
  /// Args:
  /// - query: partial destination name input
  ///
  /// Returns:
  /// - [List] of suggested destination names
  List<String> queryAutocomplete(String query) {
    return Globals.destinations.autocomplete(query);
  }

  /// find the optimal [Path] between start and end [Destination]s, with accessibility and shelter constraints
  ///
  /// Args:
  /// - startDest: start [Destination]
  /// - endDest: end [Destination]
  /// - filterStairs: whether to only consider accessible paths
  /// - filterUnsheltered: whether to only consider sheltered paths
  ///
  /// Returns:
  /// - newly-created stream of GPS positions
  Future<Path> findPath(
    Destination startDest,
    Destination endDest,
    FilterLevel filterStairs,
    FilterLevel filterUnsheltered,
  ) async {
    try {
      List edgesJson;
      int stairsLevelMet;
      int shelterLevelMet;
      if (startDest is TempDestination) {
        Map jsonObj = (await ApiCalls.use_location(
          startDest.coordinate.lat,
          startDest.coordinate.lng,
          startDest.coordinate.floor,
          endDest.name,
          filterStairs,
          filterUnsheltered,
        ));
        edgesJson = jsonObj['edges'].sublist(1);
        stairsLevelMet = jsonObj['stairsPref'];
        shelterLevelMet = jsonObj['shelterPref'];
      } else {
        Map jsonObj = await ApiCalls.shortest_path(
          startDest.name,
          endDest.name,
          filterStairs,
          filterUnsheltered,
        );
        edgesJson = jsonObj['edges'];
        stairsLevelMet = jsonObj['stairsPref'];
        shelterLevelMet = jsonObj['shelterPref'];
      }
      await Globals.nodes.fetch([
        for (Map edgeInfo in edgesJson) edgeInfo["start"],
        if (edgesJson.isNotEmpty) edgesJson.last['end'],
      ]);
      List<Edge> edges = [];
      for (Map edgeInfo in edgesJson) {
        EdgeType type = EdgeType.get(edgeInfo["type"]);
        if (type == EdgeType.waitForBus) {
          edges.add(
            WaitForBusEdge(
              type,
              await Globals.nodes.get(edgeInfo["start"]),
              await Globals.nodes.get(edgeInfo["end"]),
              edgeInfo["sheltered"],
              edgeInfo["stairs"],
              edgeInfo["duration"].toDouble(),
              // edgeInfo["services"], /// ADD BEFORE FLIGHT
              ["D1", "A2", "P"], /// REMOVE BEFORE FLIGHT
            ),
          );
        } else {
          edges.add(
            Edge(
              type,
              await Globals.nodes.get(edgeInfo["start"]),
              await Globals.nodes.get(edgeInfo["end"]),
              edgeInfo["sheltered"],
              edgeInfo["stairs"],
              edgeInfo["duration"].toDouble(),
            ),
          );
        }
      }
      return Path.autoJoin(
        edges,
        startDest,
        endDest,
        stairsLevelMet >= filterStairs.level,
        shelterLevelMet >= filterUnsheltered.level,
      );
    } on EdgelessPathException catch (e) {
      return EdgelessPath(startDest, endDest);
    } on ImpossiblePathException catch (e) {
      return ImpossiblePath(startDest, endDest);
    }
  }

  /// retrieve [Destination]s nearest to selected [TempDestination]
  ///
  /// Args:
  /// - currentSelection: [TempDestination] wrapping a [Coordinate]
  ///
  /// Returns:
  /// - [List] of destinations
  Future<List<Destination>> getNearbyDestinations(
    TempDestination currentSelection,
  ) async {
    return Globals.destinations.getNearby(
      currentSelection.coordinate,
      Defaults.nearbyDestinationsCount,
    );
  }

  /// retrieve vacant [Venue]s nearest to selected [Node]
  ///
  /// Args:
  /// - currentSelection: [Node] wrapping a [Coordinate]
  ///
  /// Returns:
  /// - [List] of [Venue]s
  Future<List<Venue>> getVacantVenues(
    Node node,
    int dayOfWeek,
    Period period,
  ) async {
    period = period.truncated(Defaults.venueBookingUnit);
    List venues = await ApiCalls.near_rooms(
      node.coordinate.lat,
      node.coordinate.lng,
      Defaults.nearbyVenuesCount,
      Constants.daysOfWeek[dayOfWeek],
      period.startHHMM(),
      period.endHHMM(),
    );
    return [
      for (Map venue in venues)
        Venue(
          venue['name'],
          Coordinate(venue['lat'], venue['lng'], venue['floor']),
          [
            for (Map period in venue['occupied'])
              Period.fromISO8601(period['from'], period['to']),
          ],
        ),
    ];
  }

  void startTracking() async {
    cancelTracking();
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: Defaults.gpsUpdateThreshold,
    );
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    trackingStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position? position) {
            if (position != null) {
              trackedPositions.add(
                TimedPosition(
                  Coordinate(
                    position.latitude,
                    position.longitude,
                    position.floor ?? 0,
                  ),
                  position.timestamp,
                ),
              );
            }
          },
        );
  }

  void cancelTracking() {
    if (trackingStream != null) {
      trackingStream!.cancel();
      trackedPositions = [];
    }
  }

  void submitTracking(Path path) async {
    print(trackedPositions);
    List<TimedPosition> positions = trackedPositions;
    cancelTracking();
    List<Node> nodes = path.intermediateNodes();
    if (positions.length < nodes.length) {
      return;
    } // ADD BEFORE FLIGHT
    await ApiCalls.contribute_route(
      [for (Node node in nodes) node.name],
      [
        for (TimedPosition position in fitTrackingData(path, positions))
          position.getTimeStamp(),
      ],
    );
  }

  /// find the matching of intermediate [Node]s of a [Path] to [TimedPosition]s, such
  /// that the timestamps of successive [Node]s are ascending, and MSE of MSE is minimised
  /// Args:
  /// - positions: sorted by time
  @visibleForTesting
  List<TimedPosition> fitTrackingData(Path path, List<TimedPosition> positions) {
    // positions = [
    //   for (int i = 0; i< 100; i++)
    //   TimedPosition(
    //     Coordinate(1.403+Random().nextDouble()/100, 103.908+Random().nextDouble()/100, 0),
    //     DateTime.now().subtract(Duration(seconds: 100-i)),
    //   ),
    // ]; // STUB: REMOVE BEFORE FLIGHT
    List<Node> nodes = path.intermediateNodes();
    List<List<double>> dp = [List.filled(positions.length + 1, 0)];
    Haversine haversine = Haversine();
    double errorFn(LatLng pt1, LatLng pt2) {
      return haversine.distance(pt1, pt2);
    }

    for (int numNodes = 1; numNodes < nodes.length + 1; numNodes++) {
      dp.add(List.filled(positions.length + 1, double.infinity));
      for (int numPos = 1; numPos < positions.length + 1; numPos++) {
        dp[numNodes][numPos] = min(
          dp[numNodes][numPos - 1],
          dp[numNodes - 1][numPos - 1] +
              errorFn(
                nodes[numNodes - 1].getLatLng(),
                positions[numPos - 1].getLatLng(),
              ),
        );
      }
    }
    List<TimedPosition> res = List.filled(nodes.length, positions.first);
    int numPos = positions.length;
    int numNodes = nodes.length;
    while (numNodes > 0) {
      if (dp[numNodes][numPos - 1] <= dp[numNodes][numPos]) {
        numPos--;
      } else {
        res[numNodes - 1] = positions[numPos - 1];
        numNodes--;
        numPos--;
      }
    }
    return res;
  }
}
