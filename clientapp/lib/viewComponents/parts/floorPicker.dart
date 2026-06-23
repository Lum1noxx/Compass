import 'package:clientapp/constants.dart';
import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/themes.dart';
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
            color: AppTheme.colors.primary,
            border: Border.all(color: AppTheme.colors.tertiary, width: 2),
            shape: BoxShape.circle,
          ),
          child: SizedBox(
            width: Defaults.iconSize,
            height: Defaults.iconSize,
            child: DropdownButton<String>(
              icon: SizedBox.shrink(),
              isExpanded: true,
              dropdownColor: AppTheme.colors.primary,
              underline: SizedBox.shrink(),
              value: Floors.getName(widget.vm.selectedFloor),
              items: [
                for (int floor in Constants.floors)
                  DropdownMenuItem(
                    value: Floors.getName(floor),
                    alignment: Alignment.center,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.transparent),
                      child: Text(
                        Floors.getName(floor),
                        style: TextStyle(color: AppTheme.colors.neutral),
                      ),
                    ),
                  ),
              ],
              onChanged: (floor) => widget.onFloorNameSelect(floor!),
            ),
          ),
        );
      },
    );
  }
}
