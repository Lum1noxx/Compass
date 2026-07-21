import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/main.dart';
import 'package:clientapp/themes.dart';
import 'package:clientapp/viewmodels/searchVM.dart';
import 'package:clientapp/viewmodels/directionsBaseVM.dart';
import 'package:clientapp/viewmodels/pageVM.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:toastification/toastification.dart';

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
/// - tracking: whether tracking user movements
class NavigationVM extends DirectionsBaseVM {
  Path lastRoute = EmptyPath();
  Segment? segmentInFocus;
  Destination? newStartDest;
  Destination? newEndDest;
  bool settingEnd = false; // else, setting start
  FilterLevel filterStairs = FilterLevel.none;
  FilterLevel filterUnsheltered = FilterLevel.none;
  bool tracking = false;

  NavigationVM(super.navigator, super.model);

  /// use the selected [Destination] when returning from [SearchVM]
  ///
  /// sets either [newStartDest] or [newEndDest], depending on [settingEnd]
  @override
  void returnFrom(PageVM child) {
    if (child is SearchVM) {
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
  void setFilterStairs(int filter) {
    filterStairs = FilterLevel.get(filter);
    notifyListeners();
  }

  /// setter for [filterUnsheltered]
  void setFilterUnsheltered(int filter) {
    filterUnsheltered = FilterLevel.get(filter);
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
      model.cancelTracking();
      lastRoute = path;
      segmentInFocus = path.isValid() ? path.segments.first : null;
      nodeInFocus = start;
      if (path is EdgelessPath) {
        toastification.show(
          title: Text("start location coincides with end location"),
          type: ToastificationType.error,
          autoCloseDuration: Duration(seconds: 5),
        );
      } else if (path is ImpossiblePath) {
        toastification.show(
          title: Text("unable to find a route"),
          type: ToastificationType.error,
          autoCloseDuration: Duration(seconds: 5),
        );
      } else if (!path.shelterFilterMet || !path.stairFilterMet) {
        toastification.show(
          title: Text(
            "unable to find routes for filters: ${path.stairFilterMet ? "" : "handicap accessibility, "}${path.shelterFilterMet ? "" : "shelter"}",
          ),
          type: ToastificationType.warning,
          description: Text("showing next-best route!"),
          autoCloseDuration: Duration(seconds: 5),
        );
      }

      notifyListeners();
      openPanel();
    });
  }

  /// navigate to [SearchVM] to search for a [Destination] by name
  ///
  /// searches for either [newStartDest] or [newEndDest], depending on [settingEnd]
  ///
  /// Args
  /// - settingEnd: whether to search for [newEndDest]
  void searchDestination(bool settingEnd) {
    this.settingEnd = settingEnd;
    navTo("search");
    notifyListeners();
  }

  /// swap [newStartDest] and [newEndDest]
  void swapDestinations() {
    Destination? temp = newStartDest;
    newStartDest = newEndDest;
    newEndDest = temp;
    notifyListeners();
  }

  void cancelTracking() {
    tracking = false;
    model.cancelTracking();
    notifyListeners();
  }

  void startTracking() {
    tracking = true;
    model.startTracking();
    toastification.show(
      title: Text("Tracking started"),
      description: Text(
        style: TextStyle(color: AppTheme.colors.neutral),
        "Select \"Submit\" once you arrive at your destination to submit tracking data.\nSelect \"Cancel\" to delete tracking data.",
      ),
      backgroundColor: AppTheme.colors.background,
      type: ToastificationType.info,
      autoCloseDuration: Duration(seconds: 10),
    );
    notifyListeners();
  }

  void submitTracking() {
    tracking = false;
    model.submitTracking(lastRoute);
     toastification.show(
      title: Text("Tracking data submitted"),
      description: Text(
        style: TextStyle(color: AppTheme.colors.neutral),
        "Thank you for your contribution!",
      ),
      type: ToastificationType.success,
      backgroundColor: AppTheme.colors.background,
      autoCloseDuration: Duration(seconds: 5),
    );
    notifyListeners();
  }
}
