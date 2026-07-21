import 'package:clientapp/constants.dart';
import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/themes.dart';
import 'package:clientapp/viewmodels/directionsBaseVM.dart';
import 'package:clientapp/viewmodels/venuesVM.dart';
import 'package:flutter/material.dart';

class DayOfWeekPicker extends StatefulWidget {
  final VenuesVM vm;
  final void Function(int) onDayOfWeekSelect;

  const DayOfWeekPicker(this.vm, this.onDayOfWeekSelect, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _DayOfWeekPickerState();
  }
}

class _DayOfWeekPickerState extends State<DayOfWeekPicker> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (ctx, child) {
        return DecoratedBox(
          decoration: BoxDecoration(color: AppTheme.colors.primary),
          child: DropdownMenu<int>(
            showTrailingIcon: false,
            initialSelection: widget.vm.vacantDayOfWeek,
            expandedInsets: EdgeInsets.zero,
            dropdownMenuEntries: [
              for (int dow = 0; dow < Constants.daysOfWeek.length; dow++)
                DropdownMenuEntry(
                  value: dow,
                  label: Constants.daysOfWeek[dow],
                  labelWidget: Container(
                    decoration: BoxDecoration(color: Colors.transparent),
                    child: Text(
                      Constants.daysOfWeek[dow],
                      style: TextStyle(color: AppTheme.colors.neutral),
                    ),
                  ),
                ),
            ],
            onSelected: (dow) => widget.onDayOfWeekSelect(dow!),
          ),
        );
      },
    );
  }
}
