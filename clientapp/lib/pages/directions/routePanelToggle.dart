import 'package:flutter/material.dart';

class RoutePanelToggle extends StatelessWidget {
  
  final void Function() onToggle;
  
  const RoutePanelToggle(this.onToggle, {super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onToggle,
      icon: Text("more")
      );
  }
  
}
