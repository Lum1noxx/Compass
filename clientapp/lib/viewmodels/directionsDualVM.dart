import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/viewmodels/destinationSearchVM.dart';
import 'package:clientapp/viewmodels/directionsBaseVM.dart';
import 'package:clientapp/viewmodels/pageVM.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

/// viewmodel for dual directions page
///
/// this page is for user to find and view a [Path] by specifying start and end [Destination]s
/// 
/// public members:
/// - lastRoute: most recent [Path] requested by user
///   - initally [EmptyPath] when no request has been made yet
/// - segmentInFocus: most recent [Segment] selected by user, if any
/// - newStartDest: user-selected start [Destination] for the next [Path], if any
/// - newEndDest: user-selected end [Destination] for the next [Path], if any
/// - settingEnd: whether the user is currently selecting [newEndDest]
///   - else, user is selecting [newStartDest]
/// - filterStairs: whether to only consider accessible paths for the next [Path]
/// - filterUnsheltered: whether to only consider sheltered paths for the next [Path]
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

  /// use the selected [Destination] when returning from [DestinationSearchVM]
  /// 
  /// sets either [newStartDest] or [newEndDest], depending on [settingEnd]
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

  /// setter for [filterStairs]
  void setFilterStairs(bool filter) {
    filterStairs = filter;
    notifyListeners();
  }

  /// setter for [filterUnsheltered]
  void setFilterUnsheltered(bool filter) {
    filterUnsheltered = filter;
    notifyListeners();
  }

  /// pan to and zoom in on the user selection ([nodeInFocus] or [segmentInFocus]) on the map
  /// 
  /// if there is both [nodeInFocus] and [segmentInFocus], [nodeInFocus] takes priority
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


  /// set a [Node] or [Segment] as the user selection
  /// 
  /// if [item] is [Node], set both [nodeInFocus] and [segmentInFocus]
  ///   - [segmentInFocus] is set by locating [item] in [lastRoute]
  ///   - keep the original [segmentInFocus] if there is no [Segment] containing [item] in [lastRoute]
  /// if [item] is [Segment], only set [segmentInFocus]
  /// 
  /// Args:
  /// - item: user-selected [Node] or [Segment]
  /// - keepSegment: whether to keep the original [segmentInFocus] when setting [nodeInFocus]
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

  /// find the optimal [Path] between [newStartDest] and [newEndDest], considering [filterStairs] and [filterUnsheltered]
  /// 
  /// do nothing is either [newStartDest] or [newEndDest] is missing
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

  /// navigate to [DestinationSearchVM] to search for a [Destination] by name
  /// 
  /// searches for either [newStartDest] or [newEndDest], depending on [settingEnd]
  /// 
  /// Args
  /// - settingEnd: whether to search for [newEndDest]
  void searchDestination(bool settingEnd) {
    this.settingEnd = settingEnd;
    navTo("destinationSearch");
    notifyListeners();
  }

  /// swap [newStartDest] and [newEndDest]
  void swapDestinations() {
    Destination? temp = newStartDest;
    newStartDest = newEndDest;
    newEndDest = temp;
    notifyListeners();
  }
}
