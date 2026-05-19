import 'package:clientapp/data.dart';
import 'package:clientapp/mainActivity.dart';
import 'package:clientapp/models/directionsModel.dart';
import 'package:clientapp/viewmodels/directionsVM.dart';
import 'package:flutter/material.dart';

class DirectionsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DirectionsPageState(DirectionsVM(DirectionsModel()));
  }
}

class _DirectionsPageState extends State<DirectionsPage> {
  _DirectionsPageState(this.vm);
  DirectionsVM vm;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(children: [
      Expanded(flex: 10, child: CampusMap(vm)),
      Expanded(flex: 2, child: SearchBar((txt)=>vm.queryAutocomplete(txt))),
      Expanded(flex: 5, child: DestinationList(vm)),
      Expanded(flex: 2, child: ButtonRow(vm))
    ]);
  }
}

class CampusMap extends StatefulWidget {
  CampusMap(this.vm);
  DirectionsVM vm;
  @override
  State<CampusMap> createState() => _CampusMapState();
}

class _CampusMapState extends State<CampusMap> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (ctx, child)=>ListView(children: [
      Row(children: [Text("start: "), Text(widget.vm.mapStartDest?.toString()??"none")]),
      Row(children: [Text("end: "), Text(widget.vm.mapEndDest?.toString()??"none")]),
      for (int i = 0; i < widget.vm.mapPath.length; i++)
        Row(children: [Text("step $i: "), Text(widget.vm.mapPath[i].toString())],)
    ],));
    

  }
}

class SearchBar extends StatelessWidget {
  const SearchBar(this.onChangeCallback);
  final void Function(String) onChangeCallback;
  @override
  Widget build(BuildContext context) {
    return TextField(onChanged: onChangeCallback);
  }
}

class DestinationList extends StatefulWidget {
  DestinationList(this.vm);
  DirectionsVM vm;
  @override
  State<DestinationList> createState() => _DestinationListState();
}

class _DestinationListState extends State<DestinationList> {
  @override
  Widget build(BuildContext context) {
    void Function(String) onPressCallback = (dest) => widget.vm.setDest(dest);
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (ctx, child)=>  ListView(children: [
        for (String dest in widget.vm.autocompleteResults)
          DestinationRow(dest, onPressCallback)
      ],),
    );
  }
}

class DestinationRow extends StatelessWidget {
  const DestinationRow(this.name, this.onPressCallback);
  final void Function(String) onPressCallback;
  final String name;
  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: ()=>onPressCallback(name), child: Text(name));
  }
}

class ButtonRow extends StatefulWidget {
  ButtonRow(this.vm);
  DirectionsVM vm;

  @override
  State<ButtonRow> createState() => _ButtonRowState();
}

class _ButtonRowState extends State<ButtonRow> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (ctx, child)=>Row(children: [
        Expanded(child: TextButton(onPressed: (){
          if (widget.vm.settingEnd) {
            widget.vm.toggleSettingEnd();
          }
        }, child: DecoratedBox(
              decoration: BoxDecoration(color: widget.vm.settingEnd ? Colors.blueGrey : Colors.yellow),
              child: Text(widget.vm.newStartDest == null ? "start" : widget.vm.newStartDest!.name)
            )
          )
        ),
        Expanded(child: TextButton(onPressed: (){
          if (!widget.vm.settingEnd) {
            widget.vm.toggleSettingEnd();
          }
        }, child: DecoratedBox(
              decoration: BoxDecoration(color: widget.vm.settingEnd ? Colors.yellow : Colors.blueGrey),
              child: Text(widget.vm.newEndDest == null ? "end" : widget.vm.newEndDest!.name)
            )
          )
        ),
        Expanded(child: TextButton(onPressed: widget.vm.findPath, child: Text("find directions")))
      ],),
    );
  }
}