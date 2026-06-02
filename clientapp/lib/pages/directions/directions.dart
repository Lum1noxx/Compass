import 'package:clientapp/constants.dart';
import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/models/directionsModel.dart';
import 'package:clientapp/pages/directions/bottomControls/bottomControls.dart';
import 'package:clientapp/pages/directions/map/abstractMarker.dart';
import 'package:clientapp/pages/directions/map/map.dart';
import 'package:clientapp/pages/directions/middleControls/middleControls.dart';
import 'package:clientapp/pages/directions/routePanel/routePanel.dart';
import 'package:clientapp/pages/directions/suggestions/suggestions.dart';
import 'package:clientapp/viewmodels/directionsVM.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class DirectionsPage extends StatefulWidget {

  late final DirectionsVM vm;
  late final void Function() gpsOnClick;
  late final void Function(String) searchbarOnEdit;
  late final void Function(LatLng) pinDropCallback;
  late final void Function() searchbarOnEditComplete;
  late final void Function(String) onFloorNameSelect;
  late final void Function(String) onDestNameSelect;
  late final void Function(bool) onSettingEndChanged;
  late final void Function() onRoutePanelToggle;
  late final void Function(Node) onRoutePanelNodeSelect;
  late final void Function(Segment) onRoutePanelSegmentSelect;
  late final void Function(Edge) onEdgeMarkerTap;

  DirectionsPage({super.key}) {
    vm = DirectionsVM(DirectionsModel());
    gpsOnClick = () {
      vm.pinDropLatLng(vm.gps?.getLatLng() ?? Defaults.mapPosition);
    };
    searchbarOnEdit = (txt) {
      vm.queryAutocomplete(txt);
    };
    pinDropCallback = (LatLng position) {
      vm.pinDropLatLng(position);
    };
    searchbarOnEditComplete = () {
      vm.searchBarFocusNode.unfocus();
    };
    onFloorNameSelect = (floor) => vm.selectFloor(floor);
    onDestNameSelect = (dest) => vm.setDestByName(dest);
    onSettingEndChanged = (settingEnd) {
      if (settingEnd != vm.settingEnd) {
        vm.toggleSettingEnd();
      }
    };
    onRoutePanelToggle = () {
      vm.toggleRoutePanel();
    };
    onRoutePanelNodeSelect = (node){
      if (node is Destination) {
        vm.setDest(node);
      } else {
        vm.focusItem(node);
      }
    };
    onRoutePanelSegmentSelect = (segment){
      vm.focusItem(segment);
    };
    onEdgeMarkerTap = (edge) {
      vm.focusItem(edge);
    };
  }

  @override
  State<StatefulWidget> createState() {
    return _DirectionsPageState();
  }

}

class _DirectionsPageState extends State<DirectionsPage> {

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(flex:1, child: RoutePanelToggle(widget.onRoutePanelToggle)),
      Expanded(
        flex: 10, 
        child: ListenableBuilder(
          listenable: widget.vm,
          builder: (context, child) {
            return Row(
              children: [
                Expanded(flex: 2, child: CampusMap(widget.vm, widget.pinDropCallback, widget.onEdgeMarkerTap)),
                if (widget.vm.showRoutePanel)
                  Expanded(flex: 1, child: RoutePanel(widget.vm, widget.onRoutePanelNodeSelect, widget.onRoutePanelSegmentSelect))
              ],
            );
          }
        )
      ),
      
      Expanded(flex: 2, child: MiddleActionsRow(widget.vm, widget.searchbarOnEdit, widget.searchbarOnEditComplete, widget.onFloorNameSelect, widget.gpsOnClick)),
      Expanded(flex: 5, child: Suggestions(widget.vm, widget.onDestNameSelect)),
      Expanded(flex: 2, child: BottomControls(widget.vm, widget.onSettingEndChanged))
    ]);
  }

}
