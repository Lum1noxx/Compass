import 'package:clientapp/data.dart';
import 'package:clientapp/models/directionsModel.dart';
import 'package:flutter/material.dart';

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
  
  void setDest(String destName) {
    if (settingEnd) {
      newEndDest = model.getDest(destName);
    } else {
      newStartDest = model.getDest(destName);
    }
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