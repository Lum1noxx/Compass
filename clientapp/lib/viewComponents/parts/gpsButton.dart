import 'package:clientapp/defaults.dart';
import 'package:flutter/material.dart';

class GpsButton extends StatelessWidget {

  final void Function() onSelect;

  const GpsButton(this.onSelect, {super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: Defaults.iconSize,
      onPressed: onSelect,
      alignment: Alignment.center,
      icon: Icon(Icons.gps_fixed_rounded)
    );
  }

}

