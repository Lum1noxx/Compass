import 'package:clientapp/defaults.dart';
import 'package:clientapp/themes.dart';
import 'package:clientapp/viewComponents/parts/atomic.dart';
import 'package:flutter/material.dart';

class GpsButton extends StatelessWidget {
  final void Function() onSelect;

  const GpsButton(this.onSelect, {super.key});

  @override
  Widget build(BuildContext context) {
    return LabeledIcon.icon(Icons.gps_fixed_rounded, "GPS", colorOverride: AppTheme.colors.tertiary, onSelect: onSelect,);
    // return IconButton(
    //   iconSize: Defaults.iconSize,
    //   onPressed: onSelect,
    //   alignment: Alignment.center,
    //   color: AppTheme.colors.tertiary,
    //   icon: Icon(Icons.gps_fixed_rounded),
    // );
  }
}
