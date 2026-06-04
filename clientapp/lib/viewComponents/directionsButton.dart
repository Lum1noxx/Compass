import 'package:clientapp/defaults.dart';
import 'package:flutter/material.dart';

class DirectionsButton extends StatelessWidget {

  final void Function() onSelect;

  const DirectionsButton(this.onSelect, {super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onSelect,
      alignment: Alignment.center,
      iconSize: Defaults.iconSize,
      icon: Icon(Icons.directions));
  }
}