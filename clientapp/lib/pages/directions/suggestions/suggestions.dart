import 'package:clientapp/viewmodels/directionsVM.dart';
import 'package:flutter/material.dart';

class Suggestions extends StatefulWidget {

  final DirectionsVM vm;
  final void Function(String) onDestNameSelect;

  const Suggestions(this.vm, this.onDestNameSelect, {super.key});

  @override
  State<Suggestions> createState() => _SuggestionsState();

}

class _SuggestionsState extends State<Suggestions> {

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (ctx, child)=>  ListView(children: [
        for (String dest in widget.vm.autocompleteResults)
          if (widget.vm.newStartDest != null && dest == widget.vm.newStartDest!.name)
            DestinationRow(dest, widget.onDestNameSelect, Colors.yellow)
          else if (widget.vm.newEndDest != null && dest == widget.vm.newEndDest!.name)
            DestinationRow(dest, widget.onDestNameSelect, Colors.yellow)
          else
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
