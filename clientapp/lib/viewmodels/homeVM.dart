import 'package:clientapp/data.dart';
import 'package:clientapp/viewmodels/searchVM.dart';
import 'package:clientapp/viewmodels/directionsBaseVM.dart';
import 'package:clientapp/viewmodels/navigationVM.dart';
import 'package:clientapp/viewmodels/pageVM.dart';

/// viewmodel for single directions page
///
/// this page is for user to locate and view particular [Destination]s on a map
class HomeVM extends DirectionsBaseVM {
  HomeVM(super.navigator, super.model);

  /// use the selected [Destination] when returning from [SearchVM]
  @override
  void returnFrom(PageVM child) {
    if (child is SearchVM) {
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

  /// navigate to [SearchVM] to search for a [Destination] by name
  void searchDestination() {
    navTo("search");
    notifyListeners();
  }

  /// navigate to [NavigationVM] to search for a [Path]
  ///
  /// use [nodeInFocus], if any, as the end [Destination]
  void findPath() {
    navTo("navigation");
  }
}
