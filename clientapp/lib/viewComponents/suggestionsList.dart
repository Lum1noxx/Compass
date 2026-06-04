import 'package:clientapp/viewmodels/destinationSearchVM.dart';
import 'package:flutter/material.dart';

class SuggestionsList extends StatefulWidget {

  final DestinationSearchVM vm;
  final void Function(String) onDestNameSelect;

  const SuggestionsList(this.vm, this.onDestNameSelect, {super.key});

  @override
  State<SuggestionsList> createState() => _SuggestionsListState();

}

class _SuggestionsListState extends State<SuggestionsList> {

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (ctx, child)=>  ListView(children: [
        for (String dest in widget.vm.autocompleteResults)
            DestinationRow(dest, widget.onDestNameSelect)
      ],),
    );
  }

}

class DestinationRow extends StatelessWidget {

  final void Function(String) onPressCallback;
  final String name;
  final Color highlight;

  const DestinationRow(this.name, this.onPressCallback, [this.highlight = Colors.transparent]);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: highlight),
      child: TextButton(onPressed: ()=>onPressCallback(name), child: Text(name)));
  }

}
