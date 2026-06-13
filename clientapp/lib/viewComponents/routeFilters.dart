import 'package:clientapp/defaults.dart';
import 'package:clientapp/themes.dart';
import 'package:clientapp/viewmodels/directionsDualVM.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RouteFilters extends StatefulWidget {
  final DirectionsDualVM vm;
  final void Function(bool) onFilterStairsChange;
  final void Function(bool) onFilterUnshelteredChange;

  const RouteFilters(
    this.vm,
    this.onFilterStairsChange,
    this.onFilterUnshelteredChange, {
    super.key,
  });

  @override
  State<RouteFilters> createState() => _RouteFiltersState();
}

class _RouteFiltersState extends State<RouteFilters> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StairsFilter(widget.vm.filterStairs, widget.onFilterStairsChange),
            ShelterFilter(
              widget.vm.filterUnsheltered,
              widget.onFilterUnshelteredChange,
            ),
          ],
        );
      },
    );
  }
}

class ShelterFilter extends SingleFilter {
  ShelterFilter(bool checked, void Function(bool) onCheckChange, {super.key})
    : super(
        Icon(
          CupertinoIcons.umbrella_fill,
          size: Defaults.iconSize,
          color: AppTheme.colors.neutral,
        ),
        checked,
        onCheckChange,
      );
}

class StairsFilter extends SingleFilter {
  StairsFilter(bool checked, void Function(bool) onCheckChange, {super.key})
    : super(
        Icon(
          Icons.accessible_forward,
          size: Defaults.iconSize,
          color: AppTheme.colors.neutral,
        ),
        checked,
        onCheckChange,
      );
}

class SingleFilter extends StatelessWidget {
  final Widget icon;
  final bool checked;
  final void Function(bool) onCheckChange;

  const SingleFilter(this.icon, this.checked, this.onCheckChange, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        SizedBox(
          width: Defaults.switchSize,
          child: FittedBox(child: Switch(
            activeTrackColor: AppTheme.colors.accent,
            activeThumbColor: AppTheme.colors.primary,
            inactiveThumbColor: AppTheme.colors.neutral,
            inactiveTrackColor: AppTheme.colors.secondary,
            value: checked,
            onChanged: onCheckChange
            ))
          ),
      ],
    );
  }
}
