import 'dart:async';

import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/floorplans.dart';
import 'package:clientapp/models/directionsModel.dart';
import 'package:clientapp/viewmodels/pageVM.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

abstract class DirectionsBaseVM extends PageVM {
  bool useSelectedFloor = false;
  int selectedFloor = 0;
  List<OverlayImage> visibleFloorplans = [];
  List<Destination> nearbyDestinations = [];
  dynamic itemInFocus; // Node or Segment

  DirectionsModel model;
  MapController mapController = MapController();
  StreamSubscription? gpsStream;
  TempDestination? gps;
  bool showLegend = true;


  DirectionsBaseVM(super.navigator, this.model) {
    model.streamGPS((position) {
      gps = TempDestination.plane(position);
      notifyListeners();
    }).then((stream)=> gpsStream = stream);
  }

  @override void dispose() {
    super.dispose();
    mapController.dispose();
    if (gpsStream != null) {
      gpsStream!.cancel();
    }
  }

  @override void onPause() {
    if (gpsStream != null) {
      gpsStream!.pause();
    }
  }

  @override void onExit() {
    mapController.dispose();
  }

  @override
  void onEnter() {
    mapController = MapController();
  }

  @override
  void onResume() {
    if (gpsStream != null) {
      gpsStream!.resume();
    }
  }

  void selectFloor(String floor) {
    if (floor == "all") {
      useSelectedFloor = false;
    } else {
      useSelectedFloor = true;
      selectedFloor = Floors.getFloor(floor);
      visibleFloorplans = floorplans.get(selectedFloor);
      notifyListeners();
    }
  }
  

  void notifyMapCamera() {
    if (itemInFocus is Node) {
      mapController.move(itemInFocus.getLatLng(), Defaults.mapFocusZoom);
    } else if (itemInFocus is Segment) {
      mapController.fitCamera(CameraFit.bounds(
        bounds: itemInFocus.getBounds(),
        padding: EdgeInsets.all(Defaults.segmentViewPadding)
      ));
    }
  }

  void pinDropLatLng(LatLng position) async {
    itemInFocus = TempDestination(Coordinate(position.latitude, position.longitude, selectedFloor));
    notifyMapCamera();
    nearbyDestinations = await model.getNearbyDestinations(itemInFocus!);
    notifyListeners();
  }

  void toggleLegend() {
    showLegend = !showLegend;
    notifyListeners();
  }


}