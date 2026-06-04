import 'package:clientapp/viewmodels/pageChangeVM.dart';
import 'package:flutter/material.dart';

abstract class PageVM extends ChangeNotifier {
/// page lifecycle: 
/// nav in: enter -> call -> pause -> bind -> resume -> exit
/// nav out: enter -> return -> pause -> bind -> resume -> exit
  
  PageChangeVM navigator;

  PageVM(this.navigator);

  void navTo(String page) {
    navigator.navTo(page);
  }

  void navBack() {
    navigator.navBack();
  }

  void onEnter() {
  /// called before binding to widget
  }

  void onResume() {
  /// called after binding to widget

  }

  void onPause() {
  /// called before unbinding widget
  }

  void onExit() {
  /// called after unbinding widget
  }

  void callTo(PageVM child);

  void returnFrom(PageVM child);

}

class TerminalPageVM extends PageVM {

  TerminalPageVM(super.navigator);
  
  @override
  void callTo(PageVM child) {
    // DONOTHING
  }

  @override
  void returnFrom(PageVM child) {
    // DONOTHING
  }

}