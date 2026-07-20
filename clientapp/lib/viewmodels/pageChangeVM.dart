import 'dart:io';

import 'package:clientapp/models/compassModel.dart';
import 'package:clientapp/pages/search/page.dart';
import 'package:clientapp/pages/navigation/page.dart';
import 'package:clientapp/pages/home/page.dart';
import 'package:clientapp/pages/venues/page.dart';
import 'package:clientapp/viewmodels/searchVM.dart';
import 'package:clientapp/viewmodels/navigationVM.dart';
import 'package:clientapp/viewmodels/homeVM.dart';
import 'package:clientapp/viewmodels/pageVM.dart';
import 'package:clientapp/viewmodels/venuesVM.dart';
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
  late String currentPageName;
  List<PageVM> navStack = [];

  /// register pages (viewmodels + views) and set home page
  /// 
  /// Args:
  /// - homePage: name of initial page. It is also the permanent bottom of navigation stack
  PageChangeVM(String homePage) {
    CompassModel model = CompassModel();
    vms = {
      'search': SearchVM(this, model),
      'navigation': NavigationVM(this, model),
      'home': HomeVM(this, model),
      'venues': VenuesVM(this, model)
    };
    pages = {
      'search': (vm) =>
          DestinationSearchWidget(vm as SearchVM),
      'navigation': (vm) =>
          DirectionsDualDestinationsWidget(vm as NavigationVM),
      'home': (vm) =>
          DirectionsSingleDestinationWidget(vm as HomeVM),
      'venues': (vm) => 
          VenuesWidget(vm as VenuesVM)
    };
    vmIndex = {for (String name in vms.keys) vms[name]!: name};
    PageVM first = vms[homePage]!;
    navStack.add(first);
    first.onEnter();
    currentPageName = homePage;
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
    currentPageName = page;
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
    currentPageName = vmIndex[to]!;
    currentPage = pages[currentPageName]!(to);
    notifyListeners();
    to.onResume();
    from.onExit();
  }
}
