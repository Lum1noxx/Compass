import 'dart:async';
import 'package:clientapp/UserExceptions.dart';
import 'package:clientapp/apiCalls.dart';
import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/main.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' hide Path;

class DirectionsModel {
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
              callback.call(LatLng(position.latitude, position.longitude));
            }
          },
        );
    return stream;
  }

  Future<Destination> getDest(String destName) async {
    return Globals.destinations.get(destName);
  }

  List<String> queryAutocomplete(String query) {
    return Globals.destinations.autocomplete(query);
  }

  Future<Path> findPath(
    Destination startDest,
    Destination endDest,
    bool filterStairs,
    bool filterUnsheltered,
  ) async {
    try {
      List<Map> edgesJson = await ApiCalls.shortest_path(
        startDest.name,
        endDest.name,
        !filterStairs,
        !filterUnsheltered,
      );
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

  Future<List<Destination>> getNearbyDestinations(currentSelection) async {
    currentSelection = currentSelection as TempDestination;
    return Globals.destinations.getNearby(
      currentSelection.coordinate,
      Defaults.nearbyDestinationsCount,
    );
  }
}
