import 'dart:async';

import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/models/directionsModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DirectionsVM extends ChangeNotifier {
  DirectionsVM(this.model) {
    mapPath = [];
    autocompleteResults = [];
    nearbyDestinations = [];
    settingEnd = false;
    gpsStream = model.streamGPS((position) {
      gps = TempDestination.plane(position);
      notifyListeners();
    });
  }

  Destination? mapStartDest;
  Destination? mapEndDest;

  late List<Edge> mapPath;
  late List<String> autocompleteResults;
  late List<Destination> nearbyDestinations;

  Destination? newStartDest;
  Destination? newEndDest;

  dynamic currentSelection = null; // Node or Dest

  late bool settingEnd; // else, setting start
  late int selectedFloor = 0;
  bool useSelectedFloor = false;
  TempDestination? gps = null;
  
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
    mapController.move(currentSelection.getLatLng(), Defaults.mapFocusZoom);
  }

  void pinDropLatLng(LatLng position) async {
    currentSelection = TempDestination(Coordinate(position.latitude, position.longitude, selectedFloor));
    notifyMapView();
    nearbyDestinations = await model.getNearbyDestinations(currentSelection);
    notifyListeners();
  }

  void selectNodeByName(String nodeName) {
    selectNode(model.getNodeOnPath(nodeName));
  }
  
  void selectNode(Node node) {
    currentSelection = node;
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
    currentSelection = destination;
    notifyMapView();
    notifyListeners();
  }

  void queryAutocomplete(String query) {
    autocompleteResults = model.queryAutocomplete(query);
    notifyListeners();
  }

  void findPath() async{
    if (newStartDest!=null && newEndDest!=null){
      mapStartDest = newStartDest;
      mapEndDest = newEndDest;
      model.findPath(newStartDest!, newEndDest!).then((path){mapPath=path; notifyListeners();});
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
      notifyListeners();
    }

  }
}