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

/// abstract base viewmodel for route-finding pages with a map UI 
/// 
/// public members:
/// - gps: current GPS location, if available
/// - showLegend: whether the map legend is visible
/// - selectedFloor: floor number selected by user
/// - visibleFloorplans: avaiable floorplans for the [selectedFloor]
/// - nearbyDestinations: [List] of [Destination]s nearest to user-selected [Coordinate]
///   - empty if no user-selected [Coordinate]
/// - nodeInFocus: most recent [Node] selected by user, if any
///   - can also be [Destination] or its subtypes 
abstract class DirectionsBaseVM extends PageVM {
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

  /// ensure that all controllers and streams are cleaned up
  @override
  void dispose() {
    super.dispose();
    mapController.dispose();
    panelController.dispose();
    if (gpsStream != null) {
      gpsStream!.cancel();
    }
  }

  /// ensure that all streams are paused
  @override
  void onPause() {
    if (gpsStream != null) {
      gpsStream!.pause();
    }
  }

  /// ensure that all controllers are cleaned up
  @override
  void onExit() {
    mapController.dispose();
    panelController.dispose();
  }

  /// reset controllers for binding
  @override
  void onEnter() {
    mapController = MapController();
    panelController = ExpandableController();
  }

  /// resume all paused streams
  @override
  void onResume() {
    if (gpsStream != null) {
      gpsStream!.resume();
    }
  }

  /// set [selectedFloor] by the user-selected floor name
  /// 
  /// also update [visibleFloorplans] accordingly
  void selectFloor(String floor) {
      selectedFloor = Floors.getFloor(floor);
      visibleFloorplans = floorplans.get(selectedFloor);
      notifyListeners();
  }

  /// pan to and zoom in on [nodeInFocus] on the map
  void notifyMapCamera() {
    if (nodeInFocus != null) {
      mapController.move(nodeInFocus!.getLatLng(), Defaults.mapFocusZoom);
    }
  }

  /// open the bottom sheet panel
  void openPanel() {
    if (!panelController.expanded) {
      panelController.toggle();
    }
  }

  /// set a [Node] as the user selection
  /// 
  /// Args:
  /// - item: user-selected [Node]
  void focusItem(dynamic item) {
    assert(item is Node);
    nodeInFocus = item;
    notifyMapCamera();
    notifyListeners();
    openPanel();
  }

  /// select a [Coordinate] by creating and selecting a [TempDestination] 
  /// 
  /// Floor number is taken from [selectedFloor]. also fetches and updates [nearbyDestinations]
  /// 
  /// Args:
  /// - position: [LatLng]
  void pinDropLatLng(LatLng position) async {
    TempDestination dest = TempDestination(
      Coordinate(position.latitude, position.longitude, selectedFloor),
    );
    nearbyDestinations = await model.getNearbyDestinations(dest);
    focusItem(dest);
  }

  /// toggle the visisbility of the map legend
  void toggleLegend() {
    showLegend = !showLegend;
    notifyListeners();
  }

  /// check whether the selected data item is on the [selectedFloor]
  /// 
  /// an [Edge] is on [selectedFloor] is any of its nodes are on [selectedFloor]
  /// 
  /// Args:
  /// - item: [Node] or [Edge] to check
  /// 
  /// Return:
  /// - whether [item] is on [selectedFloor]
  bool isOnCurrentFloor(dynamic item) {
    // Node or edge
    if (item is Node) {
      return selectedFloor == item.coordinate.floor;
    } else if (item is Edge) {
      return isOnCurrentFloor(item.start) || isOnCurrentFloor(item.end);
    } else {
      throw UnsupportedError("bad item type");
    }
  }
}
