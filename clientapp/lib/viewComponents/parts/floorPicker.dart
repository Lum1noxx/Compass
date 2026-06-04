import 'package:clientapp/constants.dart';
import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/viewmodels/directionsBaseVM.dart';
import 'package:flutter/material.dart';

class FloorPicker extends StatefulWidget {

  final DirectionsBaseVM vm;
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
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            shape: BoxShape.circle
            ),
          child: Container(
            width: Defaults.iconSize,
            height: Defaults.iconSize,
            padding: const EdgeInsets.all(6.0),
            child: DropdownButton<String>(
                icon: SizedBox.shrink(),
                underline: SizedBox.shrink(),
                isDense: true,
                value: widget.vm.useSelectedFloor ? Floors.getName(widget.vm.selectedFloor) : "all",
                items: [
                  DropdownMenuItem(value: "all", child: Text("all", style: TextStyle(backgroundColor: Colors.grey.shade800, color: Colors.white))),
                  for (int floor in Constants.floors)
                    DropdownMenuItem(value: Floors.getName(floor), child: Text(Floors.getName(floor), style: TextStyle(backgroundColor: Colors.grey.shade800, color: Colors.white)))
                ],
                onChanged: (floor) => widget.onFloorNameSelect(floor!)
              ),
          ),
        );
      }
    );
  }

}
