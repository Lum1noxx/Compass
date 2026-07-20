import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/themes.dart';
import 'package:clientapp/viewmodels/navigationVM.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RouteFilters extends StatefulWidget {
  final NavigationVM vm;
  final void Function(int) onFilterStairsChange;
  final void Function(int) onFilterUnshelteredChange;

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
  ShelterFilter(
    FilterLevel level,
    final void Function(int) onFilterChange, {
    super.key,
  }) : super(
         Icon(
           CupertinoIcons.umbrella_fill,
           size: Defaults.iconSize,
           color: AppTheme.colors.tertiary,
         ),
         level,
         onFilterChange,
       );
}

class StairsFilter extends SingleFilter {
  StairsFilter(
    FilterLevel level,
    final void Function(int) onFilterChange, {
    super.key,
  }) : super(
         Icon(
           Icons.accessible_forward,
           size: Defaults.iconSize,
           color: AppTheme.colors.tertiary,
         ),
         level,
         onFilterChange,
       );
}

class SingleFilter extends StatelessWidget {
  final Widget icon;
  final FilterLevel level;
  final void Function(int) onFilterChange;

  const SingleFilter(this.icon, this.level, this.onFilterChange, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 0,
      children: [
        icon,
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7),
              valueIndicatorTextStyle: TextStyle(
                color: AppTheme.colors.primary,
              ),
            ),
            child: Slider(
              thumbColor: AppTheme.colors.accent,
              activeColor: AppTheme.colors.accent,
              inactiveColor: AppTheme.colors.secondary,
              value: level.level.toDouble(),
              min: 0,
              divisions: 2,
              max: 2,
              onChanged: (level) => onFilterChange(level.round()),
              label: level.name,
              padding: EdgeInsets.all(10),
            ),
          ),
        ),
      ],
    );
  }
}
