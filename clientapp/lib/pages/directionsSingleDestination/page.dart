import 'package:clientapp/defaults.dart';
import 'package:clientapp/pages/directionsSingleDestination/callbacks.dart';
import 'package:clientapp/viewComponents/campusMap.dart';
import 'package:clientapp/viewComponents/directionsButton.dart';
import 'package:clientapp/viewComponents/parts/floorPicker.dart';
import 'package:clientapp/viewComponents/parts/gpsButton.dart';
import 'package:clientapp/viewComponents/panelHeader.dart';
import 'package:clientapp/viewComponents/panelInfo.dart';
import 'package:clientapp/viewComponents/searchBarButton.dart';
import 'package:clientapp/viewmodels/directionsSingleVM.dart';

import 'package:latlong2/latlong.dart';

import 'dart:ui';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';


class DirectionsSingleDestinationWidget extends StatefulWidget {

  final DirectionsSingleVM vm;

  const DirectionsSingleDestinationWidget(this.vm, {super.key});

  @override
  State<DirectionsSingleDestinationWidget> createState() =>
      _DirectionsSingleDestinationWidgetState();
}

class _DirectionsSingleDestinationWidgetState
    extends State<DirectionsSingleDestinationWidget> {
  late DirectionsSingleDestinationCallbacks callbacks;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    callbacks = DirectionsSingleDestinationCallbacks(widget.vm);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ExpandableController panelExpandController = ExpandableController();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // {{SearchBarButton}}
              Container(
                width: 100,
                height: 50,
                decoration: BoxDecoration(
                ),
                child: SearchBarButton(widget.vm.itemInFocus?.name ?? "search:", callbacks.onSearchBarButtonSelect),
              ),
              Expanded(
                flex: 10,
                child: CampusMap(widget.vm, callbacks.onPinDrop, callbacks.onDestSelect, callbacks.onFloorNameSelect, callbacks.onGpsSelect, callbacks.onLegendToggle),
              ),

              ExpandableNotifier(
                controller: panelExpandController,
                child: ExpandablePanel(
                  header: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // {{PanelHeader}}
                      Expanded(
                        flex: 10,
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            panelExpandController.toggle();
                          },
                          child: Container(
                            width: 100,
                            height: 50,
                            decoration: BoxDecoration(
                            ),
                            child: PanelHeader(widget.vm),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            panelExpandController.toggle();
                          },
                          child: Container(
                            width: 100,
                            height: 50,
                            decoration: BoxDecoration(),
                          ),
                        ),
                      ),

                      // {{directionsButton}}
                      Expanded(
                        flex: 2,
                        child: Container(
                          width: 100,
                          height: 50,
                          decoration: BoxDecoration(
                          ),
                          child: DirectionsButton(callbacks.onDirectionSelect),
                        ),
                      ),
                    ],
                  ),
                  collapsed: Container(
                    width: double.infinity,
                    height: 0,
                    decoration: BoxDecoration(
                    ),
                  ),
                  expanded:
                      // {{PanelInfo}}
                      Container(
                    width: double.infinity,
                    height: MediaQuery.sizeOf(context).height * 0.4,
                    decoration: BoxDecoration(
                    ),
                    child: PanelInfo(widget.vm),
                  ),
                  theme: ExpandableThemeData(
                    tapHeaderToExpand: false,
                    tapBodyToExpand: false,
                    tapBodyToCollapse: false,
                    headerAlignment: ExpandablePanelHeaderAlignment.center,
                    hasIcon: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
