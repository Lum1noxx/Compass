import 'package:clientapp/data.dart';
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
  
  final DirectionsModel model;
  final MapController mapController = MapController();
  final TextEditingController searchBarController = TextEditingController();
  final FocusNode searchBarFocusNode = FocusNode();


  @override void dispose() {
    super.dispose();
    mapController.dispose();
    searchBarController.dispose();
    searchBarFocusNode.dispose();
  }

  void pinDropLatLng(LatLng position) async {
    currentSelection = TempDestination(Coordinate(position.latitude, position.longitude, selectedFloor));
    mapController.move(currentSelection.getLatLng(), 18);
    nearbyDestinations = await model.getNearbyDestinations(currentSelection);
    notifyListeners();
  }

  void selectNodeByName(String nodeName) {
    selectNode(model.getNodeOnPath(nodeName));
  }
  
  void selectNode(Node node) {
    currentSelection = node;
    mapController.move(currentSelection.getLatLng(), 18);
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
    mapController.move(currentSelection.getLatLng(), 18);
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
}