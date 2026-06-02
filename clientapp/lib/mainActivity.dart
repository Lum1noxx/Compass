import 'package:clientapp/pages/about.dart';
import 'package:clientapp/pages/directions/directions.dart';
import 'package:clientapp/viewmodels/pageChangeVM.dart';
import 'package:flutter/material.dart';

PageChangeVM vm = PageChangeVM(DirectionsPage());

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
      return Column(children: [
        Expanded(flex: 1, child: TopBar(vm.currentPage)),
        Expanded(flex: 12, child: vm.currentPage),
        Expanded(flex: 1, child: NavigationBar())
      ],);
    });
    
  }
}

class TopBar extends StatelessWidget {
  TopBar(Widget page, {super.key}) {
    if (page is DirectionsPage) {
      pageName = "Directions";
    } else if (page is AboutPage) {
      pageName = "About";
    } else {
      pageName = "invalid";
    }
  }
  late String pageName;
  @override
  Widget build(BuildContext context) {
    return Row(children: [Text(pageName)]);
  }
}

class NavigationBar extends StatelessWidget {
  const NavigationBar({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(flex: 1, child: DecoratedBox(
        decoration: BoxDecoration(color: (vm.currentPage is DirectionsPage) ? Colors.yellow : Colors.blueGrey),
        child: TextButton(onPressed: ()=>vm.navigateTo(DirectionsPage()), child: Text("directions")))) ,
      Expanded(flex: 1, child: DecoratedBox(
        decoration: BoxDecoration(color: (vm.currentPage is AboutPage) ? Colors.yellow : Colors.blueGrey),
        child: TextButton(onPressed: ()=>vm.navigateTo(AboutPage()), child: Text("about")))) ,
    ],);
  }
}