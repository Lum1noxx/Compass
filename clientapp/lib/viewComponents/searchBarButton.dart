import 'package:flutter/material.dart';

class SearchBarButton extends StatelessWidget {
  
  final String destName;
  final void Function() onSelect;

  const SearchBarButton(this.destName, this.onSelect, {super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onSelect, 
      icon: Text(destName)
    );
  }
}