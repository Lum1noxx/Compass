import 'package:auto_size_text/auto_size_text.dart';
import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/themes.dart';
import 'package:clientapp/viewComponents/parts/atomic.dart';
import 'package:clientapp/viewmodels/venuesVM.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class _TimeOfDayPicker extends StatefulWidget {
  final VenuesVM vm;
  final void Function(TimeOfDay) onSelect;
  final TimeOfDay Function(VenuesVM) timeStateAccessor;
  final Widget icon;

  const _TimeOfDayPicker({
    required this.vm,
    required this.icon,
    required this.onSelect,
    required this.timeStateAccessor,
  });

  @override
  State<StatefulWidget> createState() {
    return _TimeOfDayPickerState();
  }
}

class _TimeOfDayPickerState extends State<_TimeOfDayPicker> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (ctx, child) {
        return IconButton(
          onPressed: () async {
            widget.onSelect(
              await showTimePicker(
                    context: ctx,
                    initialTime: widget.timeStateAccessor(widget.vm),
                  ) ??
                  widget.timeStateAccessor(widget.vm),
            );
          },
          icon: Row(
            children: [
              widget.icon,
              Expanded(
                child: AutoSizeText(
                  widget.timeStateAccessor(widget.vm).format(ctx),
                  minFontSize: Defaults.autoTextMin,
                  maxFontSize: Defaults.autoTextMax,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.colors.neutralAccent),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class StartTimePicker extends _TimeOfDayPicker {
  StartTimePicker(VenuesVM vm, void Function(TimeOfDay) onSelect)
    : super(
        onSelect: onSelect,
        vm: vm,
        icon: LabeledIcon.icon(
          CupertinoIcons.clock,
          "start",
          iconSizeOverride: 24,
          labelHeightOverride: 10,
        ),
        timeStateAccessor: (vm) => vm.vacantStart,
      );
}

class EndTimePicker extends _TimeOfDayPicker {
  EndTimePicker(VenuesVM vm, void Function(TimeOfDay) onSelect)
    : super(
        onSelect: onSelect,
        vm: vm,
        icon: LabeledIcon.icon(
          CupertinoIcons.clock,
          "end",
          iconSizeOverride: 24,
          labelHeightOverride: 10,
        ),
        timeStateAccessor: (vm) => vm.vacantEnd,
      );
}
