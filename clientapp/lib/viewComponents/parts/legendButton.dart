import 'package:clientapp/defaults.dart';
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
        height: Defaults.legendHeight,
        width: Defaults.iconSize,
        child: expanded ? HideLegend() : ShowLegend(),
      ) 
    );
  }

}

class HideLegend extends StatelessWidget {
  
  const HideLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.arrow_back_ios);
  }
}

class ShowLegend extends StatelessWidget {
  
  const ShowLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.arrow_forward_ios);
  }
}

