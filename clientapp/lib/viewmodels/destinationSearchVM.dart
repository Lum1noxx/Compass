import 'package:clientapp/data.dart';
import 'package:clientapp/models/directionsModel.dart';
import 'package:clientapp/viewmodels/pageVM.dart';
import 'package:flutter/material.dart';

class DestinationSearchVM extends TerminalPageVM {
  DestinationSearchVM(super.navigator, this.model);

  List<String> autocompleteResults = [];
  //-- RETURN
  Destination? selection;

  DirectionsModel model;
  FocusNode focusNode = FocusNode();
  TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
    controller.dispose();
  }

  @override
  void onExit() {
    focusNode.dispose();
    controller.dispose();
  }

  @override
  void onEnter() {
    focusNode = FocusNode();
    controller = TextEditingController();
  }

  @override
  void onResume() {
    focusNode.requestFocus();
  }

  void queryAutocomplete(String query) {
    autocompleteResults = model.queryAutocomplete(query);
    notifyListeners();
  }

  void setDestByName(String name) async {
    selection = await model.getDest(name);
    navBack();
  }
}
