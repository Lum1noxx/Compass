import 'package:clientapp/constants.dart';
import 'package:clientapp/data.dart';
import 'package:clientapp/viewmodels/directionsVM.dart';
import 'package:flutter/material.dart';

class FloorPicker extends StatefulWidget {

  final DirectionsVM vm;
  final void Function(String) onFloorNameSelect;

  const FloorPicker(this.vm, this.onFloorNameSelect, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _FloorPickerState();
  }

}

class _FloorPickerState extends State<FloorPicker> {

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (ctx, child) {
        return DropdownButton<String>(
            value: widget.vm.useSelectedFloor ? Floors.getName(widget.vm.selectedFloor) : "all",
            items: [
              DropdownMenuItem(value: "all", child: Text("all")),
              for (int floor in Constants.floors)
                DropdownMenuItem(value: Floors.getName(floor), child: Text(Floors.getName(floor)))
            ],
            onChanged: (floor) => widget.onFloorNameSelect(floor!)
          );
      }
    );
  }

}
