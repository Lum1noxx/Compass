import 'package:auto_size_text/auto_size_text.dart';
import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/themes.dart';
import 'package:clientapp/viewComponents/parts/edgeLines.dart';
import 'package:flutter/material.dart';

class BusServicesIcon extends StatelessWidget {
  final List<String> services;

  const BusServicesIcon(this.services);
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 2,
      children: [for (String service in services) Expanded(child: SingleServiceIcon(service))],
    );
  }
}

class SingleServiceIcon extends StatelessWidget {
  final String name;

  const SingleServiceIcon(this.name);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: AppTheme.colors.accent,
      ),
      alignment: AlignmentGeometry.center,
      child: AutoSizeText(
        name,
        minFontSize: Defaults.autoTextMin,
        maxFontSize: Defaults.autoTextMax,
        maxLines: 1,
        style: TextStyle(color: AppTheme.colors.primary, ),
      ),
    );
  }
}
