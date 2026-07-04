import 'package:clientapp/pages/venues/callbacks.dart';
import 'package:clientapp/themes.dart';
import 'package:clientapp/viewComponents/searchBar.dart';
import 'package:clientapp/viewComponents/suggestionsList.dart';
import 'package:clientapp/viewmodels/searchVM.dart';
import 'package:clientapp/viewmodels/venuesVM.dart';

import 'package:flutter/material.dart' hide SearchBar;

class VenuesWidget extends StatefulWidget {
  final VenuesVM vm;

  const VenuesWidget(this.vm, {super.key});

  @override
  State<VenuesWidget> createState() =>
      _VenuesWidgetState();
}

class _VenuesWidgetState extends State<VenuesWidget> {
  late VenuesCallbacks callbacks;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    callbacks = VenuesCallbacks(widget.vm);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppTheme.colors.background,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
         
            ],
          ),
        ),
      ),
    );
  }
}
