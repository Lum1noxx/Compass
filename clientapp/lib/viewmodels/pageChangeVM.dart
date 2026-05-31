import 'package:flutter/material.dart';

class PageChangeVM extends ChangeNotifier {
  PageChangeVM(this.currentPage);
  Widget currentPage;
  void navigateTo(Widget page) {
    currentPage = page;
    notifyListeners();
  }
}