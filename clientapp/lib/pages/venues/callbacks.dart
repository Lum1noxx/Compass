import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/viewmodels/venuesVM.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class VenuesCallbacks {
  late final void Function() onSearchBarButtonSelect;
  late final void Function(LatLng) onPinDrop;
  late final void Function(String) onFloorNameSelect;
  late final void Function() onGpsSelect;
  late final void Function(Destination) onVenueSelect;
  late final void Function() onLegendToggle;
  late final void Function() onFindSelect;
  late final void Function(int) onDayOfWeekSelect;
  late final void Function(TimeOfDay) onStartTimeSelect;
  late final void Function(TimeOfDay) onEndTimeSelect;
  VenuesCallbacks(VenuesVM vm) {
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

    onVenueSelect = (dest) {
      vm.focusItem(dest);
    };
    onLegendToggle = () {
      vm.toggleLegend();
    };
    onFindSelect = () {
      vm.findVenues();
    };
    onDayOfWeekSelect = (dow) {
      vm.setDayOfWeek(dow);
    };
    onStartTimeSelect = (time) {
      vm.setVacantStart(time);
    };
    onEndTimeSelect = (time) {
      vm.setVacantEnd(time);
    };
  }
}
