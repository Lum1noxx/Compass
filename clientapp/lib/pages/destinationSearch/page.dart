import 'package:clientapp/pages/destinationSearch/callbacks.dart';
import 'package:clientapp/viewComponents/searchBar.dart';
import 'package:clientapp/viewComponents/suggestionsList.dart';
import 'package:clientapp/viewmodels/destinationSearchVM.dart';

import 'package:flutter/material.dart' hide SearchBar;

class DestinationSearchWidget extends StatefulWidget {
  final DestinationSearchVM vm;

  const DestinationSearchWidget(this.vm, {super.key});

  @override
  State<DestinationSearchWidget> createState() =>
      _DestinationSearchWidgetState();
}

class _DestinationSearchWidgetState extends State<DestinationSearchWidget> {
  late DestinationSearchCallbacks callbacks;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    callbacks = DestinationSearchCallbacks(widget.vm);
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
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // {{SearchBar}}
              Container(
                width: 100,
                height: 50,
                decoration: BoxDecoration(),
                child: SearchBar(
                  widget.vm,
                  callbacks.onSearchBarEdit,
                  callbacks.onSearchBarComplete,
                ),
              ),

              // {{SuggestionsList}}
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional(0, 0),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(),
                    child: SuggestionsList(
                      widget.vm,
                      callbacks.onDestNameSelect,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
