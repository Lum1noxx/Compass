import 'dart:async';
import 'dart:convert';

import 'package:clientapp/apiCalls.dart';
import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/main.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class DirectionsModel {

  late Map<String, Node> nodesOnPath;

  StreamSubscription streamGPS(void Function(LatLng) callback) {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: Defaults.gpsUpdateThreshold,
    );
    StreamSubscription<Position> stream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position? position) {
        if (position != null) {
          callback.call(LatLng(position.latitude, position.longitude));
        }
      });
    return stream;
  }

  Future<Destination> getDest(String destName) async{
    return Globals.destinations.get(destName);
  }

  List<String> queryAutocomplete(String query) {
    return Globals.destinations.autocomplete(query);
  }

  Future<List<Edge>> findPath(Destination startDest, Destination endDest) async{
    List<Map> edgesJson = await ApiCalls.shortest_path(startDest.name, endDest.name);
    await Globals.nodes.fetch([
      for (Map edgeInfo in edgesJson)
        edgeInfo["start"],
      if (edgesJson.isNotEmpty)
        edgesJson.last['end']
    ]);
    List<Edge> path = [
      for (Map edgeInfo in edgesJson)
        Edge(
          EdgeType.get(edgeInfo["type"]),
          await Globals.nodes.get(edgeInfo["start"]),
          await Globals.nodes.get(edgeInfo["end"]),
          edgeInfo["sheltered"],
          edgeInfo["stairs"],
          edgeInfo["duration"]
        )
    ];
    nodesOnPath = {
      for (Edge edge in path)
        edge.start.name : edge.start,
      path.last.end.name : path.last.end
    };
    return path;

  }

  Node getNodeOnPath(String nodeName) {

    return nodesOnPath[nodeName]!;
  }

  Future<List<Destination>> getNearbyDestinations(currentSelection) async{
    currentSelection = currentSelection as TempDestination;
    return Globals.destinations.getNearby(currentSelection.coordinate, Defaults.nearbyDestinationsCount);
    
  }

}