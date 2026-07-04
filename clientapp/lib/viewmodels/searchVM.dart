import 'package:clientapp/data.dart';
import 'package:clientapp/models/compassModel.dart';
import 'package:clientapp/viewmodels/pageVM.dart';
import 'package:flutter/material.dart';

/// viewmodel for [Destination] search page
///
/// this page is for user to search for and select [Destination]s by name
///
/// public members:
/// - autocompleteResults: [List] of suggested [Destination] names closest to the user input
/// - selection: [Destination] selected by user, if any
class SearchVM extends TerminalPageVM {
  SearchVM(super.navigator, this.model);

  List<String> autocompleteResults = [];
  Destination? selection;

  CompassModel model;
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
    selection = null;
    autocompleteResults = [];
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

  /// update [autocompleteResults] for a new user input
  /// 
  /// Args:
  /// - query: user input
  void queryAutocomplete(String query) {
    autocompleteResults = model.queryAutocomplete(query);
    notifyListeners();
  }

  /// set [selection] based on the user-selected [Destination] name
  /// 
  /// Args:
  /// - name: user-selected [Destination] name
  void setDestByName(String name) async {
    selection = await model.getDest(name);
    navBack();
  }
}
