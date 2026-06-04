import 'package:clientapp/data.dart';
import 'package:clientapp/viewmodels/destinationSearchVM.dart';
import 'package:clientapp/viewmodels/directionsBaseVM.dart';
import 'package:clientapp/viewmodels/pageVM.dart';

class DirectionsDualVM extends DirectionsBaseVM {

  Path lastRoute = Path([]);
  Destination? newStartDest;
  Destination? newEndDest;
  bool settingEnd = false; // else, setting start


  DirectionsDualVM(super.navigator, super.model);

  // @override void onResume() {
  //   notifyListeners();
  // }

  @override
  void callTo(PageVM child) {
  }

  @override
  void returnFrom(PageVM child) {
    if (child is DestinationSearchVM) {
      if (child.selection != null) {
            if (settingEnd) {
      newEndDest = child.selection!;
      } else {
        newStartDest = child.selection!;
      }
      itemInFocus = child.selection!; 
        }
    }
  }

  void focusItem(dynamic item) {
    assert(item is Node || item is Edge || item is Segment);
    if (item is Edge) {
      itemInFocus = lastRoute.locate(item);
    } else {
      itemInFocus = item;    
    }
    notifyMapCamera();
    notifyListeners();
  }

  void setDest(Destination destination) {
    if (settingEnd) {
      newEndDest = destination;
    } else {
      newStartDest = destination;
    }
    itemInFocus = destination;
    notifyMapCamera();
    notifyListeners();
  }

  void findPath() async{
    if (newStartDest!=null && newEndDest!=null){
      model.findPath(newStartDest!, newEndDest!).then((path){lastRoute=path; notifyListeners();});
    }
  }

  void searchDestination(bool settingEnd) {
    this.settingEnd = settingEnd;
    navTo("destinationSearch");
    notifyListeners();
  }

  void swapDestinations() {
    Destination? temp = newStartDest;
    newStartDest = newEndDest;
    newEndDest = temp;
    notifyListeners();
  }

}