import 'package:clientapp/data.dart';
import 'package:clientapp/viewmodels/destinationSearchVM.dart';
import 'package:clientapp/viewmodels/directionsBaseVM.dart';
import 'package:clientapp/viewmodels/directionsDualVM.dart';
import 'package:clientapp/viewmodels/pageVM.dart';

/// viewmodel for single directions page
///
/// this page is for user to locate and view particular [Destination]s on a map
class DirectionsSingleVM extends DirectionsBaseVM {
  DirectionsSingleVM(super.navigator, super.model);

  /// when navigating to [DirectionsDualVM], set the end [Destination] to this [nodeInFocus], if any
  @override
  void callTo(PageVM child) {
    if (child is DestinationSearchVM) {
    } else if (child is DirectionsDualVM) {
      child.newStartDest = null;
      child.newEndDest = nodeInFocus as Destination?;
    }
  }

  /// use the selected [Destination] when returning from [DestinationSearchVM]
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
    super.onResume();
    openPanel();
  }

  /// navigate to [DestinationSearchVM] to search for a [Destination] by name
  void searchDestination() {
    navTo("destinationSearch");
    notifyListeners();
  }

  /// navigate to [DirectionsDualVM] to search for a [Path]
  /// 
  /// use [nodeInFocus], if any, as the end [Destination]
  void findPath() {
    navTo("directionsDual");
  }
}
