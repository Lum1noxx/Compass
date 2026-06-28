import 'dart:io';

import 'package:clientapp/models/directionsModel.dart';
import 'package:clientapp/pages/destinationSearch/page.dart';
import 'package:clientapp/pages/directionsDualDestination/page.dart';
import 'package:clientapp/pages/directionsSingleDestination/page.dart';
import 'package:clientapp/viewmodels/destinationSearchVM.dart';
import 'package:clientapp/viewmodels/directionsDualVM.dart';
import 'package:clientapp/viewmodels/directionsSingleVM.dart';
import 'package:clientapp/viewmodels/pageVM.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// viewmodel for main activity, handles page navigation
/// 
/// callback sequence:
/// - nav to: enter -> call -> pause -> bind -> resume -> exit
/// - nav back: enter -> return -> pause -> bind -> resume -> exit
/// 
/// public members:
/// - currentPage: active page
class PageChangeVM extends ChangeNotifier {
  late Map<String, PageVM> vms;
  late Map<String, Widget Function(PageVM)> pages;

  late Map<PageVM, String> vmIndex;

  late Widget currentPage;
  List<PageVM> navStack = [];

  /// register pages (viewmodels + views) and set home page
  /// 
  /// Args:
  /// - homePage: name of initial page. It is also the permanent bottom of navigation stack
  PageChangeVM(String homePage) {
    DirectionsModel model = DirectionsModel();
    vms = {
      'destinationSearch': DestinationSearchVM(this, model),
      'directionsDual': DirectionsDualVM(this, model),
      'directionsSingle': DirectionsSingleVM(this, model),
    };
    pages = {
      'destinationSearch': (vm) =>
          DestinationSearchWidget(vm as DestinationSearchVM),
      'directionsDual': (vm) =>
          DirectionsDualDestinationsWidget(vm as DirectionsDualVM),
      'directionsSingle': (vm) =>
          DirectionsSingleDestinationWidget(vm as DirectionsSingleVM),
    };
    vmIndex = {for (String name in vms.keys) vms[name]!: name};
    PageVM first = vms[homePage]!;
    navStack.add(first);
    first.onEnter();
    currentPage = pages[homePage]!(first);
    first.onResume();
  }
  
  /// navigate to a new page, pushing onto navigation stack
  /// 
  /// callback sequence:
  /// - enter -> call -> pause -> bind -> resume -> exit
  /// 
  /// Args:
  /// - page: name of new page
  void navTo(String page) {
    PageVM from = navStack.last;
    PageVM child = vms[page]!;
    navStack.add(child);
    child.onEnter();
    from.callTo(child);
    from.onPause();
    currentPage = pages[page]!(child);
    notifyListeners();
    child.onResume();
    from.onExit();
  }

  /// return to the previous page, popped from navigation stack
  /// 
  /// callback sequence:
  /// - enter -> return -> pause -> bind -> resume -> exit
  void navBack() {
    if (navStack.length < 2) {
      return;
    }
    PageVM from = navStack.removeLast();
    PageVM to = navStack.last;
    to.onEnter();
    to.returnFrom(from);
    from.onPause();
    currentPage = pages[vmIndex[to]]!(to);
    notifyListeners();
    to.onResume();
    from.onExit();
  }
}
