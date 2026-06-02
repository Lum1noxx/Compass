import 'dart:async';

import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/floorplans.dart';
import 'package:clientapp/models/directionsModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;

class DirectionsVM extends ChangeNotifier {
  DirectionsVM(this.model) {
    lastRoute = Path([]);
    autocompleteResults = [];
    nearbyDestinations = [];
    settingEnd = false;
    gpsStream = model.streamGPS((position) {
      gps = TempDestination.plane(position);
      notifyListeners();
    });
  }

  late Path lastRoute;
  late List<String> autocompleteResults;
  late List<Destination> nearbyDestinations;

  Destination? newStartDest;
  Destination? newEndDest;

  dynamic itemInFocus = null; // Node or Segment

  late bool settingEnd; // else, setting start
  late int selectedFloor = 0;
  bool useSelectedFloor = false;
  List<OverlayImage> visibleFloorplans = [];
  TempDestination? gps = null;

  bool showRoutePanel = false;
  
  final DirectionsModel model;
  final MapController mapController = MapController();
  final TextEditingController searchBarController = TextEditingController();
  final FocusNode searchBarFocusNode = FocusNode();
  late StreamSubscription gpsStream;

  @override void dispose() {
    super.dispose();
    mapController.dispose();
    searchBarController.dispose();
    searchBarFocusNode.dispose();
    gpsStream.cancel();
  }

  void notifyMapView() {
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
    notifyMapView();
    nearbyDestinations = await model.getNearbyDestinations(itemInFocus);
    notifyListeners();
  }
  
  void focusItem(dynamic item) {
    assert(item is Node || item is Edge || item is Segment);
    if (item is Edge) {
      itemInFocus = lastRoute.locate(item);
    } else {
      itemInFocus = item;    
    }
    notifyMapView();
    notifyListeners();
  }

  Future<void> setDestByName(String destName) async{
    Destination dest = await model.getDest(destName);
    setDest(dest);
  }

  void setDest(Destination destination) {
    if (settingEnd) {
      newEndDest = destination;
    } else {
      newStartDest = destination;
    }
    itemInFocus = destination;
    notifyMapView();
    notifyListeners();
  }

  void queryAutocomplete(String query) {
    autocompleteResults = model.queryAutocomplete(query);
    notifyListeners();
  }

  void findPath() async{
    if (newStartDest!=null && newEndDest!=null){
      model.findPath(newStartDest!, newEndDest!).then((path){lastRoute=path; notifyListeners();});
      showRoutePanel = true;
    }
  }

  void toggleSettingEnd() {
    settingEnd = !settingEnd;
    searchBarFocusNode.requestFocus();
    searchBarController.selection = TextSelection(baseOffset: 0, extentOffset: searchBarController.text.length);
    notifyListeners();
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

  void toggleRoutePanel() {
    showRoutePanel = !showRoutePanel;
    notifyListeners();
  }
}