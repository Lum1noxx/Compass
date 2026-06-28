import 'package:clientapp/defaults.dart';
import 'package:clientapp/themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DestSwapButton extends StatelessWidget {
  final void Function() onSelect;

  const DestSwapButton(this.onSelect, {super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onSelect,
      iconSize: Defaults.iconSize,
      color: AppTheme.colors.tertiary,
      alignment: Alignment.center,
      icon: Icon(Icons.swap_vert),
    );
  }
}
