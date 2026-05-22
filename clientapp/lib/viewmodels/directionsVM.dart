import 'package:clientapp/data.dart';
import 'package:clientapp/models/directionsModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class DirectionsVM extends ChangeNotifier {
  DirectionsVM(this.model) {
    mapPath = [];
    autocompleteResults = [];
    settingEnd = false;
  }

  final DirectionsModel model;

  Destination? mapStartDest;
  Destination? mapEndDest;

  late List<Edge> mapPath;
  late List<String> autocompleteResults;

  Destination? newStartDest;
  Destination? newEndDest;

  late bool settingEnd; // else, setting start
  final MapController mapController = MapController();

  dynamic currentSelection = null;

  @override
  void notifyListeners() {
    // TODO: implement notifyListeners
    super.notifyListeners();
    if (currentSelection != null) {
      mapController.move(currentSelection.getLatLng(), 18);
    }
  }
  void selectNodeByName(String nodeName) {
    currentSelection = model.getNodeInPath(mapPath, nodeName);
    notifyListeners();
  }
  void selectNode(Node node) {
    currentSelection = node;
    notifyListeners();
  }

  void setDestByName(String destName) {
    Destination dest = model.getDest(destName);
    if (settingEnd) {
      newEndDest = dest;
    } else {
      newStartDest = dest;
    }
    currentSelection = dest;
    notifyListeners();
  }

  void setDest(Destination destination) {
    if (settingEnd) {
      newEndDest = destination;
    } else {
      newStartDest = destination;
    }
    currentSelection = destination;
    notifyListeners();
  }

  void queryAutocomplete(String query) {
    autocompleteResults = model.queryAutocomplete(query);
    notifyListeners();
  }

  void findPath() {
    if (newStartDest!=null && newEndDest!=null){
      mapStartDest = newStartDest;
      mapEndDest = newEndDest;
      model.findPath(newStartDest!, newEndDest!).then((path){mapPath=path; notifyListeners();});
    }
  }

  void toggleSettingEnd() {
    settingEnd = !settingEnd;
    notifyListeners();
  }
}