import 'package:auto_size_text/auto_size_text.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final String currentPage;
  final void Function(String) onItemSelect;

  const NavBar(this.currentPage, this.onItemSelect, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: NavBarItem(
            pageName: 'home',
            selected: currentPage,
            onSelect: onItemSelect,
            icon: Icons.map_outlined,
          ),
        ),
        Expanded(
          child: NavBarItem(
            pageName: 'navigation',
            selected: currentPage,
            onSelect: onItemSelect,
            icon: Icons.directions,
          ),
        ),
        Expanded(
          child: NavBarItem(
            pageName: 'venues',
            selected: currentPage,
            onSelect: onItemSelect,
            icon: CupertinoIcons.building_2_fill,
          ),
        ),
      ],
    );
  }
}

class NavBarItem extends StatelessWidget {
  final String selected;
  final String pageName;
  final IconData icon;
  final void Function(String) onSelect;
  const NavBarItem({
    required this.pageName,
    required this.selected,
    required this.onSelect,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.all(0),
      onPressed: () => selected != pageName ? onSelect(pageName) : () {},
      icon: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: Defaults.iconSize,
              color: selected == pageName
                  ? AppTheme.colors.neutralAccent
                  : AppTheme.colors.neutral,
            ),
            Expanded(
              child: AutoSizeText(
                minFontSize: Defaults.autoTextMin,
                maxFontSize: Defaults.autoTextMax,
                textAlign: TextAlign.center,
                maxLines: 1,
                pageName,
                style: TextStyle(
                  color: selected == pageName
                      ? AppTheme.colors.neutralAccent
                      : AppTheme.colors.neutral,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
