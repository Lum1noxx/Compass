import 'package:clientapp/data.dart';
import 'package:clientapp/viewmodels/destinationSearchVM.dart';
import 'package:clientapp/viewmodels/directionsBaseVM.dart';
import 'package:clientapp/viewmodels/directionsDualVM.dart';
import 'package:clientapp/viewmodels/pageVM.dart';

class DirectionsSingleVM extends DirectionsBaseVM {
  DirectionsSingleVM(super.navigator, super.model);

  @override
  void callTo(PageVM child) {
    if (child is DestinationSearchVM) {
    } else if (child is DirectionsDualVM) {
      child.newStartDest = null;
      child.newEndDest = nodeInFocus as Destination?;
    }
  }

  @override
  void returnFrom(PageVM child) {
    if (child is DestinationSearchVM) {
      if (child.selection is Destination) {
        nodeInFocus = child.selection;
      }
    }
  }

  @override
  void onResume() {
    openPanel();
  }

  void searchDestination() {
    navTo("destinationSearch");
    notifyListeners();
  }

  void findPath() {
    navTo("directionsDual");
  }
}
