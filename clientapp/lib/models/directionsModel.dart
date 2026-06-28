import 'dart:async';
import 'package:clientapp/UserExceptions.dart';
import 'package:clientapp/apiCalls.dart';
import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/main.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' hide Path;

/// main model for app 
/// 
/// coordinates core logic for all app features:
/// 1. Find nearby destinations
/// 2. GPS location
/// 3. search for destinations using autocomplete
/// 4. find best route between destinations and/or coordinates
class DirectionsModel {

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
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position? position) {
            if (position != null) {
              callback.call(LatLng(position.latitude, position.longitude)); /// ADD BEFORE FLIGHT
              // callback.call(LatLng(1.29445088, 103.7744729)); /// REMOVE BEFORE FLIGHT
            }
          },
        );
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
    bool filterStairs,
    bool filterUnsheltered,
  ) async {
    try {
      List<Map> edgesJson;
      if (startDest is TempDestination) {
        edgesJson = (await ApiCalls.use_location(
          startDest.coordinate.lat,
          startDest.coordinate.lng,
          startDest.coordinate.floor,
          endDest.name,
          filterStairs,
          filterUnsheltered,
        )).sublist(1);
      } else {
        edgesJson = await ApiCalls.shortest_path(
          startDest.name,
          endDest.name,
          filterStairs,
          filterUnsheltered,
        );
      }
      await Globals.nodes.fetch([
        for (Map edgeInfo in edgesJson) edgeInfo["start"],
        if (edgesJson.isNotEmpty) edgesJson.last['end'],
      ]);
      List<Edge> edges = [
        for (Map edgeInfo in edgesJson)
          Edge(
            EdgeType.get(edgeInfo["type"]),
            await Globals.nodes.get(edgeInfo["start"]),
            await Globals.nodes.get(edgeInfo["end"]),
            edgeInfo["sheltered"],
            edgeInfo["stairs"],
            edgeInfo["duration"],
          ),
      ];
      return Path.autoJoin(edges, startDest, endDest);
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
  Future<List<Destination>> getNearbyDestinations(TempDestination currentSelection) async {
    return Globals.destinations.getNearby(
      currentSelection.coordinate,
      Defaults.nearbyDestinationsCount,
    );
  }
}
