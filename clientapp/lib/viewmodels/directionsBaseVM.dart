import 'dart:async';

import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/floorplans.dart';
import 'package:clientapp/models/directionsModel.dart';
import 'package:clientapp/viewmodels/pageVM.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

abstract class DirectionsBaseVM extends PageVM {
  bool useSelectedFloor = true;
  int selectedFloor = 1;
  List<OverlayImage> visibleFloorplans = floorplans.get(1);
  List<Destination> nearbyDestinations = [];
  Node? nodeInFocus; // Node or Dest

  DirectionsModel model;
  MapController mapController = MapController();
  ExpandableController panelController = ExpandableController();
  StreamSubscription? gpsStream;
  TempDestination? gps;
  bool showLegend = true;

  DirectionsBaseVM(super.navigator, this.model) {
    model
        .streamGPS((position) {
          gps = TempDestination(Coordinate(position.latitude, position.longitude, selectedFloor));
          notifyListeners();
        })
        .then((stream) => gpsStream = stream);
  }

  @override
  void dispose() {
    super.dispose();
    mapController.dispose();
    panelController.dispose();
    if (gpsStream != null) {
      gpsStream!.cancel();
    }
  }

  @override
  void onPause() {
    if (gpsStream != null) {
      gpsStream!.pause();
    }
  }

  @override
  void onExit() {
    mapController.dispose();
    panelController.dispose();
  }

  @override
  void onEnter() {
    mapController = MapController();
    panelController = ExpandableController();
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
    if (nodeInFocus != null) {
      mapController.move(nodeInFocus!.getLatLng(), Defaults.mapFocusZoom);
    }
  }

  void openPanel() {
    if (!panelController.expanded) {
      panelController.toggle();
    }
  }

  void focusItem(dynamic item) {
    assert(item is Destination);
    nodeInFocus = item;
    notifyMapCamera();
    notifyListeners();
    openPanel();
  }

  void pinDropLatLng(LatLng position) async {
    TempDestination dest = TempDestination(
      Coordinate(position.latitude, position.longitude, selectedFloor),
    );
    nearbyDestinations = await model.getNearbyDestinations(dest);
    focusItem(dest);
  }

  void toggleLegend() {
    showLegend = !showLegend;
    notifyListeners();
  }

  bool isOnCurrentFloor(dynamic item) {
    // Node or edge
    if (!useSelectedFloor) {
      return true;
    }
    if (item is Node) {
      return !useSelectedFloor || selectedFloor == item.coordinate.floor;
    } else if (item is Edge) {
      return isOnCurrentFloor(item.start) || isOnCurrentFloor(item.end);
    } else {
      throw UnsupportedError("bad item type");
    }
  }
}
