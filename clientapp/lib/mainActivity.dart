import 'package:clientapp/defaults.dart';
import 'package:clientapp/themes.dart';
import 'package:clientapp/viewComponents/navBar.dart';
import 'package:clientapp/viewmodels/pageChangeVM.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

PageChangeVM vm = PageChangeVM('home');

class MainActivity extends StatefulWidget {
  const MainActivity({super.key});
  @override
  State<StatefulWidget> createState() {
    return _MainActivityState();
  }
}

class _MainActivityState extends State<MainActivity> {
  _MainActivityState();
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (ctx, child) {
        return Scaffold(
          bottomNavigationBar: BottomAppBar(
            padding: EdgeInsets.all(0),
            height: Defaults.iconSize*1.5,
            notchMargin: 0,
            color: AppTheme.colors.primary,
            child: SafeArea(child: NavBar(vm.currentPageName, (page) => vm.navTo(page))),
          ),
          body: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              vm.navBack();
            },
            child: KeyboardListener(
              focusNode: FocusNode(),
              autofocus: true,
              onKeyEvent: (KeyEvent event) {
                if (event is KeyDownEvent) {
                  if (event.logicalKey == LogicalKeyboardKey.escape) {
                    vm.navStack.last.navBack();
                  }
                }
              },
              child: Stack(
                children: [
                  vm.currentPage,
                  // SafeArea(
                  //   left: true,
                  //   top: true,
                  //   minimum: EdgeInsets.all(10),
                  //   child: IconButton(
                  //     iconSize: Defaults.iconSize,
                  //     alignment: Alignment.center,
                  //     color: AppTheme.colors.tertiary,
                  //     onPressed: () => vm.navStack.last.navBack(),
                  //     icon: Icon(Icons.arrow_back_ios_outlined),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
