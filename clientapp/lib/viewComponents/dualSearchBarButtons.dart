import 'package:clientapp/viewComponents/searchBarButton.dart';
import 'package:clientapp/viewmodels/directionsDualVM.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DualSearchBarButtons extends StatefulWidget {

  final DirectionsDualVM vm;
  final void Function(bool) onSearchBarButtonSelect;

  const DualSearchBarButtons(this.vm, this.onSearchBarButtonSelect,  {super.key});

  @override
  State<StatefulWidget> createState() {
    return _DualSearchBarButtonsState();
  }
}

class _DualSearchBarButtonsState extends State<DualSearchBarButtons> {

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (ctx, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedSearchBarButton(widget.vm.newStartDest?.name ?? "choose start:", ()=>widget.onSearchBarButtonSelect(false), !widget.vm.settingEnd),
            DecoratedSearchBarButton(widget.vm.newEndDest?.name ?? "choose end:", ()=>widget.onSearchBarButtonSelect(true), widget.vm.settingEnd),
          ],
        );
      }
    );
  }
}

class DecoratedSearchBarButton extends StatelessWidget {

  final bool highlighted;
  final String entry;
  final void Function() onSelect;

  const DecoratedSearchBarButton(this.entry, this.onSelect, this.highlighted, {super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: highlighted ? Colors.yellow : Colors.transparent),
      child: SearchBarButton(entry, onSelect)
    );
  }


}