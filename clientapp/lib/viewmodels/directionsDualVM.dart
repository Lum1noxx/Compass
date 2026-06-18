import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/viewmodels/destinationSearchVM.dart';
import 'package:clientapp/viewmodels/directionsBaseVM.dart';
import 'package:clientapp/viewmodels/pageVM.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class DirectionsDualVM extends DirectionsBaseVM {
  Path lastRoute = EmptyPath();
  Segment? segmentInFocus;
  Destination? newStartDest;
  Destination? newEndDest;
  bool settingEnd = false; // else, setting start
  bool filterStairs = true;
  bool filterUnsheltered = true;

  DirectionsDualVM(super.navigator, super.model);

  // @override void onResume() {
  //   notifyListeners();
  // }

  @override
  void callTo(PageVM child) {}

  @override
  void returnFrom(PageVM child) {
    if (child is DestinationSearchVM) {
      if (child.selection != null) {
        if (settingEnd) {
          newEndDest = child.selection!;
        } else {
          newStartDest = child.selection!;
        }
        nodeInFocus = child.selection!;
      }
    }
  }

  void setFilterStairs(bool filter) {
    filterStairs = filter;
    notifyListeners();
  }

  void setFilterUnsheltered(bool filter) {
    filterUnsheltered = filter;
    notifyListeners();
  }

  @override
  void notifyMapCamera() {
    if (nodeInFocus != null) {
      mapController.move(nodeInFocus!.getLatLng(), Defaults.mapFocusZoom);
    } else if (segmentInFocus != null) {
      mapController.fitCamera(
        CameraFit.bounds(
          bounds: segmentInFocus!.getBounds(),
          padding: EdgeInsets.all(Defaults.segmentViewPadding),
        ),
      );
    }
  }

  @override
  void focusItem(dynamic item, {bool keepSegment = false}) {
    assert(item is Node || item is Edge || item is Segment);
    if (item is Edge) {
      segmentInFocus = lastRoute.locate(item);
      nodeInFocus = null;
    } else if (item is Segment) {
      segmentInFocus = item;
      nodeInFocus = null;
    } else {
      // item is Node
      if (item is Destination) {
        if (settingEnd) {
          newEndDest = item;
        } else {
          newStartDest = item;
        }
      }
      nodeInFocus = item;
      if (keepSegment) {
        segmentInFocus ??= lastRoute.locate(item);
      } else {
        segmentInFocus = lastRoute.locate(item);

      }
    }
    notifyMapCamera();
    notifyListeners();
    openPanel();
  }

  void findPath() async {
    Destination? start = newStartDest ?? gps;
    Destination? end = newEndDest ?? gps;
    if (start == null || end == null) {
      return;
    }
    model.findPath(start, end, filterStairs, filterUnsheltered).then((path) {
      lastRoute = path;
      notifyListeners();
      openPanel();
    });
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
