import 'package:clientapp/defaults.dart';
import 'package:clientapp/themes.dart';
import 'package:clientapp/viewComponents/parts/atomic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DirectionsButton extends StatelessWidget {
  final void Function() onSelect;

  const DirectionsButton(this.onSelect, {super.key});

  @override
  Widget build(BuildContext context) {
    return LabeledIcon.icon(
      CupertinoIcons.arrow_up_right_diamond_fill,
      "route",
      onSelect: onSelect,
      iconSizeOverride: 40,
    );
  }
}
