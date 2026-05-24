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
  final TextEditingController searchBarController = TextEditingController();
  final FocusNode searchBarFocusNode = FocusNode();

  dynamic currentSelection = null;

  @override void dispose() {
    super.dispose();
    mapController.dispose();
    searchBarController.dispose();
    searchBarFocusNode.dispose();
  }

  void selectNodeByName(String nodeName) {
    selectNode(model.getNodeInPath(mapPath, nodeName));
  }
  
  void selectNode(Node node) {
    currentSelection = node;
    mapController.move(currentSelection.getLatLng(), 18);
    notifyListeners();
  }

  void setDestByName(String destName) async{
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