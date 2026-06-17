import 'package:clientapp/defaults.dart';
import 'package:clientapp/themes.dart';
import 'package:flutter/material.dart';

class LegendButton extends StatelessWidget {
  final void Function() onSelect;
  final bool expanded;

  const LegendButton(this.onSelect, this.expanded, {super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onSelect,
      alignment: Alignment.center,
      icon: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppTheme.colors.primary.withAlpha((0.7 * 255).round()),
        ),
        height: Defaults.legendHeight,
        width: 20,
        child: expanded ? HideLegend() : ShowLegend(),
      ),
    );
  }
}

class HideLegend extends StatelessWidget {
  const HideLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.arrow_back_ios, color: AppTheme.colors.neutral);
  }
}

class ShowLegend extends StatelessWidget {
  const ShowLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.arrow_forward_ios, color: AppTheme.colors.neutral);
  }
}
