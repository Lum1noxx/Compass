import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/viewmodels/directionsSingleVM.dart';
import 'package:latlong2/latlong.dart';

class DirectionsSingleDestinationCallbacks {
  late final void Function() onSearchBarButtonSelect;
  late final void Function(LatLng) onPinDrop;
  late final void Function(String) onFloorNameSelect;
  late final void Function() onGpsSelect;
  late final void Function() onDirectionSelect;
  late final void Function(Destination) onDestSelect;
  late final void Function() onLegendToggle;

  DirectionsSingleDestinationCallbacks(DirectionsSingleVM vm) {
    onSearchBarButtonSelect = () {
      vm.searchDestination();
    };
    onPinDrop = (LatLng position) {
      vm.pinDropLatLng(position);
    };
    onGpsSelect = () {
      vm.pinDropLatLng(vm.gps?.getLatLng() ?? Defaults.mapPosition);
    };
    onFloorNameSelect = (floor) => vm.selectFloor(floor);
    onDirectionSelect = () {
      vm.findPath();
    };
    onDestSelect = (dest) {
      vm.focusItem(dest);
    };
    onLegendToggle = () {
      vm.toggleLegend();
    };
  }
}
