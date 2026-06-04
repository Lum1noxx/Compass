import 'package:clientapp/defaults.dart';
import 'package:clientapp/viewmodels/pageChangeVM.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

PageChangeVM vm = PageChangeVM('directionsSingle');

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
    return ListenableBuilder(listenable: vm, builder: (ctx, child){
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          vm.navBack();
        },
        child: Stack(children: [
              vm.currentPage,
              IconButton(
                iconSize: Defaults.iconSize,
                alignment: Alignment.center,
                onPressed: ()=>vm.navStack.last.navBack(),
                icon: Icon(Icons.arrow_back_ios_outlined)),
            ],),
      );
    });
    
  }
}
