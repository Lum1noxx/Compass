import 'package:auto_size_text/auto_size_text.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PickOnMapButton extends StatelessWidget {
  final void Function() onSelect;

  const PickOnMapButton(this.onSelect, {super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onSelect,
      icon: Row(
        children: [
          Spacer(),
          Icon(
            CupertinoIcons.map,
            size: Defaults.iconSize,
            color: AppTheme.colors.neutral,
          ),
          Spacer(),
          Expanded(
            flex: 8,
            child: AutoSizeText(
              "Choose on map",
              minFontSize: Defaults.autoTextMin,
              maxFontSize: Defaults.autoTextMax,
              maxLines: 1,
              style: TextStyle(color: AppTheme.colors.neutral),
            ),
          ),
          SizedBox(
            width: Defaults.iconSize*2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: AppTheme.colors.secondary,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.touch_app_outlined,
                    color: AppTheme.colors.neutral,
                    size: Defaults.iconSize,
                  ),
                  AutoSizeText(
                    "Map",
                    minFontSize: Defaults.autoTextMin,
                    maxFontSize: Defaults.autoTextMax,
                    maxLines: 1,
                    style: TextStyle(color: AppTheme.colors.neutral),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
