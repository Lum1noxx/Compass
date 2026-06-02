import 'package:clientapp/pages/directions/directions.dart';
import 'package:clientapp/pages/directions/middleControls/floorPicker.dart';
import 'package:clientapp/pages/directions/middleControls/searchBar.dart';
import 'package:clientapp/viewmodels/directionsVM.dart';
import 'package:flutter/material.dart' hide SearchBar;

class MiddleActionsRow extends StatefulWidget{
  
  final DirectionsVM vm;
  final void Function(String) searchbarOnEdit;
  final void Function() searchbarOnEditComplete;
  final void Function(String) onFloorNameSelect;
  final void Function() gpsOnClick;

  const MiddleActionsRow(this.vm, this.searchbarOnEdit, this.searchbarOnEditComplete, this.onFloorNameSelect, this.gpsOnClick, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _MiddleActionsRowState();
  }

}
class _MiddleActionsRowState extends State<MiddleActionsRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 7, child: SearchBar(widget.vm, widget.searchbarOnEdit, widget.searchbarOnEditComplete)),
        Expanded(flex: 2, child: FloorPicker(widget.vm, widget.onFloorNameSelect)),
        Expanded(flex: 2, child: IconButton(
          onPressed: widget.gpsOnClick,
          icon: Text("GPS")
      ))
    ]);
  }
}
