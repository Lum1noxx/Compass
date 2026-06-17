import 'package:clientapp/defaults.dart';
import 'package:clientapp/themes.dart';
import 'package:flutter/material.dart';

class SearchBarButton extends StatelessWidget {
  final String destName;
  final void Function() onSelect;

  const SearchBarButton(this.destName, this.onSelect, {super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onSelect,
      icon: Container(
        height: Defaults.iconSize,
        decoration: BoxDecoration(
          color: AppTheme.colors.background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                destName,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.colors.neutral),
              ),
            ),
            Icon(
              Icons.search,
              color: AppTheme.colors.neutral,
              size: Defaults.iconSize,
            ),
          ],
        ),
      ),
    );
  }
}
