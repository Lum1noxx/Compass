import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/viewmodels/directionsDualVM.dart';
import 'package:latlong2/latlong.dart';

class DirectionsDualDestinationsCallbacks {
  late final void Function(LatLng) onPinDrop;
  late final void Function(String) onFloorNameSelect;
  late final void Function() onGpsSelect;
  late final void Function(bool) onSearchBarButtonSelect;
  late final void Function() onDestSwap;
  late final void Function(Edge) onEdgeMarkerTap;
  late final void Function() onFindSelect;
  late final void Function(Node) onRoutePanelNodeSelect;
  late final void Function(Segment) onRoutePanelSegmentSelect;
  late final void Function(bool) onFilterStairsChange;
  late final void Function(bool) onFilterUnshelteredChange;
  late final void Function() onLegendToggle;

  DirectionsDualDestinationsCallbacks(DirectionsDualVM vm) {
    onPinDrop = (LatLng position) {
      vm.pinDropLatLng(position);
    };
    onGpsSelect = () {
      vm.pinDropLatLng(vm.gps?.getLatLng() ?? Defaults.mapPosition);
    };
    onFloorNameSelect = (floor) => vm.selectFloor(floor);
    onSearchBarButtonSelect = (settingEnd) {
      vm.searchDestination(settingEnd);
    };
    onDestSwap = () {
      vm.swapDestinations();
    };
    onEdgeMarkerTap = (edge) {
      vm.focusItem(edge);
    };
    onFindSelect = () {
      vm.findPath();
    };
    onRoutePanelNodeSelect = (node) {
      vm.focusItem(node, keepSegment: true);
    };
    onRoutePanelSegmentSelect = (segment) {
      vm.focusItem(segment);
    };
    onFilterStairsChange = (filter) {
      vm.setFilterStairs(filter);
    };
    onFilterUnshelteredChange = (filter) {
      vm.setFilterUnsheltered(filter);
    };
    onLegendToggle = () {
      vm.toggleLegend();
    };
  }
}
