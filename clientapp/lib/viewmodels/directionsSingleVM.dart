import 'package:clientapp/data.dart';
import 'package:clientapp/viewmodels/destinationSearchVM.dart';
import 'package:clientapp/viewmodels/directionsBaseVM.dart';
import 'package:clientapp/viewmodels/directionsDualVM.dart';
import 'package:clientapp/viewmodels/pageVM.dart';
import 'package:flutter_map/flutter_map.dart';

class DirectionsSingleVM extends DirectionsBaseVM {
  Destination? selectedDest;

  DirectionsSingleVM(super.navigator, super.model);

  @override
  void callTo(PageVM child) {
    if (child is DestinationSearchVM) {
    } else if (child is DirectionsDualVM) {
      child.newEndDest = selectedDest;
    }
  }

  @override
  void returnFrom(PageVM child) {
    if (child is DestinationSearchVM) {
      if (child.selection is Destination) {
        selectedDest = child.selection;
        itemInFocus = child.selection;
      }
    }
  }

  void focusItem(dynamic item) {
    assert(item is Destination);
    itemInFocus = item;
    notifyMapCamera();
    notifyListeners();
  }

  void searchDestination() {
    navTo("destinationSearch");
    notifyListeners();
  }

  void findPath() {
    navTo("directionsDual");
  }
}
