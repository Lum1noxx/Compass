import 'package:clientapp/defaults.dart';
import 'package:clientapp/themes.dart';
import 'package:flutter/material.dart';

class FindButton extends StatelessWidget {
  final void Function() onSelect;

  const FindButton(this.onSelect, {super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onSelect,
      alignment: Alignment.center,
      iconSize: Defaults.iconSize,
      icon: Icon(Icons.assistant_navigation),
      color: AppTheme.colors.neutral,
    );
  }
}
