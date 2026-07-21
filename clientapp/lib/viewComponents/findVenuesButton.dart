import 'package:clientapp/defaults.dart';
import 'package:clientapp/themes.dart';
import 'package:clientapp/viewComponents/parts/atomic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FindVenuesButton extends StatelessWidget {
  final void Function() onSelect;

  const FindVenuesButton(this.onSelect, {super.key});

  @override
  Widget build(BuildContext context) {
    return LabeledIcon.icon(
      CupertinoIcons.building_2_fill,
      "find",
      onSelect: onSelect,
    );
  }
}
