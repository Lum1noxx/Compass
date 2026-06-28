
import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/viewmodels/destinationSearchVM.dart';

class DestinationSearchCallbacks {

  late final void Function(String) onSearchBarEdit;
  late final void Function() onSearchBarComplete;
  late final void Function(String) onDestNameSelect;

  DestinationSearchCallbacks(DestinationSearchVM vm) {
    onSearchBarEdit = (txt) {
      vm.queryAutocomplete(txt);
    };
    onSearchBarComplete = () {
      vm.focusNode.unfocus();
    };
    onDestNameSelect = (dest) => vm.setDestByName(dest);

  }

}