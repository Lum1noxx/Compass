import 'package:clientapp/defaults.dart';
import 'package:clientapp/themes.dart';
import 'package:clientapp/viewComponents/parts/atomic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FindRouteButton extends StatelessWidget {
  final void Function() onSelect;

  const FindRouteButton(this.onSelect, {super.key});

  @override
  Widget build(BuildContext context) {
    return LabeledIcon.icon(
      CupertinoIcons.location_circle_fill,
      "find",
      onSelect: onSelect,
      iconSizeOverride: 40,
    );
  }
}
