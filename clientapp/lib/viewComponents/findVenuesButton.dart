import 'package:clientapp/defaults.dart';
import 'package:clientapp/themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FindVenuesButton extends StatelessWidget {
  final void Function() onSelect;

  const FindVenuesButton(this.onSelect, {super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onSelect,
      alignment: Alignment.center,
      iconSize: Defaults.iconSize,
      icon: Icon(CupertinoIcons.building_2_fill),
      color: AppTheme.colors.neutral,
    );
  }
}
