import 'package:auto_size_text/auto_size_text.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/themes.dart';
import 'package:flutter/material.dart';

class LabeledIcon extends StatelessWidget {
  final Widget icon;
  final String label;
  final void Function()? onSelect;
  final double? iconSizeOverride;
  final double? labelHeightOverride;
  final Color? colorOverride;
  const LabeledIcon(
    this.icon,
    this.label, {
    this.onSelect,
    this.iconSizeOverride,
    this.labelHeightOverride,
    this.colorOverride,
    super.key,
  });
  LabeledIcon.icon(
    final IconData icon,
    final String label, {
    final void Function()? onSelect,
    final Color? colorOverride,
    final double? iconSizeOverride,
    final double? labelHeightOverride,
    final Key? key,
  }) : this(
         Icon(
           icon,
           size: iconSizeOverride ?? Defaults.iconSize,
           color: colorOverride ?? AppTheme.colors.neutral,
         ),
         label,
         onSelect: onSelect,
         iconSizeOverride: iconSizeOverride,
         labelHeightOverride: labelHeightOverride,
         colorOverride: colorOverride,
         key: key,
       );
  @override
  Widget build(BuildContext context) {
    double iconSize = iconSizeOverride ?? Defaults.iconSize;
    double labelHeight = labelHeightOverride ?? Defaults.labelHeight;
    Widget combined = SizedBox(
      width: iconSize + labelHeight,
      height: iconSize + labelHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: FittedBox(alignment: AlignmentGeometry.center, child: icon),
          ),
          SizedBox(
            width: iconSize+labelHeight,
            height: labelHeight,
            child: Align(
              alignment: AlignmentGeometry.topCenter,
              child: AutoText(label, maxLines: 1, colorOverride: colorOverride,),
            ),
          ),
        ],
      ),
    );
    if (onSelect == null) {
      return combined;
    } else {
      return IconButton(
        iconSize: iconSize + labelHeight,
        onPressed: onSelect,
        icon: combined,
        padding: EdgeInsets.all(3),
      );
    }
  }
}

class AutoText extends StatelessWidget {
  final String text;
  final int maxLines;
  final Color? colorOverride;

  const AutoText(this.text, {required this.maxLines, this.colorOverride});

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      minFontSize: Defaults.autoTextMin,
      maxFontSize: Defaults.autoTextMax,
      maxLines: maxLines,

      style: TextStyle(
        leadingDistribution: TextLeadingDistribution.even,
        height: 1.0,
        fontWeight: FontWeight.bold,
        color: colorOverride ?? AppTheme.colors.neutral,
      ),
      textAlign: TextAlign.center,
    );
  }
}
