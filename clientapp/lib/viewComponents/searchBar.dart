import 'package:clientapp/viewmodels/destinationSearchVM.dart';
import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {

  final DestinationSearchVM vm;
  final void Function(String) onChangeCallback;
  final void Function() onEditingComplete;

  SearchBar(this.vm, this.onChangeCallback, this.onEditingComplete, {super.key}){
    vm.focusNode.addListener((){
      if (vm.focusNode.hasFocus) {
        vm.controller.selection = TextSelection(baseOffset: 0, extentOffset: vm.controller.text.length);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Enter location:"
      ),
      focusNode: vm.focusNode,
      controller: vm.controller,
      onChanged: onChangeCallback,
      selectAllOnFocus: true,
      enableInteractiveSelection: true,
      onEditingComplete: onEditingComplete,
      );
  }

}
