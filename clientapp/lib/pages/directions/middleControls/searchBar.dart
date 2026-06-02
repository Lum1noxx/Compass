import 'package:clientapp/viewmodels/directionsVM.dart';
import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {

  final DirectionsVM vm;
  final void Function(String) onChangeCallback;
  final void Function() onEditingComplete;

  SearchBar(this.vm, this.onChangeCallback, this.onEditingComplete, {super.key}){
    vm.searchBarFocusNode.addListener((){
      if (vm.searchBarFocusNode.hasFocus) {
        vm.searchBarController.selection = TextSelection(baseOffset: 0, extentOffset: vm.searchBarController.text.length);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Enter location:"
      ),
      focusNode: vm.searchBarFocusNode,
      controller: vm.searchBarController,
      onChanged: onChangeCallback,
      selectAllOnFocus: true,
      enableInteractiveSelection: true,
      onEditingComplete: onEditingComplete,
      );
  }

}
