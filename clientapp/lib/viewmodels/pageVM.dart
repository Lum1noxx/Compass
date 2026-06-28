import 'package:clientapp/viewmodels/pageChangeVM.dart';
import 'package:flutter/material.dart';

/// abstract base viewmodel for single page
/// 
/// callback sequence:
/// - nav to: enter -> call -> pause -> bind -> resume -> exit
/// - nav back: enter -> return -> pause -> bind -> resume -> exit
abstract class PageVM extends ChangeNotifier {

  PageChangeVM navigator;

  PageVM(this.navigator);

  /// navigate to a new page, pushing onto navigation stack
  /// 
  /// callback sequence:
  /// - enter -> call -> pause -> bind -> resume -> exit
  /// 
  /// Args:
  /// - page: name of new page
  void navTo(String page) {
    navigator.navTo(page);
  }

  /// return to the previous page, popped from navigation stack
  /// 
  /// callback sequence:
  /// - enter -> return -> pause -> bind -> resume -> exit
  void navBack() {
    navigator.navBack();
  }
  
  void onEnter() {
  }

  void onResume() {
  }

  void onPause() {
  }

  void onExit() {
  }

  /// pass data to the new page before binding
  /// 
  /// Args:
  /// - child: viewmodel of new page getting navigated to
  void callTo(PageVM child);

  /// retrieve data from a child page before binding
  /// 
  /// Args:
  /// - child: viewmodel of child page getting returned from
  void returnFrom(PageVM child);
}

/// convenience [PageVM] wrapper for terminal pages with no navigation children
abstract class TerminalPageVM extends PageVM {
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
