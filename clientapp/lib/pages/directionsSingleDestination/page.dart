import 'package:clientapp/defaults.dart';
import 'package:clientapp/pages/directionsSingleDestination/callbacks.dart';
import 'package:clientapp/themes.dart';
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        body: Stack(
          children: [
            Column(
              children: [
                // {{CampusMap}}
                Expanded(
                  child: CampusMap(
                    widget.vm,
                    callbacks.onPinDrop,
                    callbacks.onDestSelect,
                    callbacks.onFloorNameSelect,
                    callbacks.onGpsSelect,
                    callbacks.onLegendToggle,
                  ),
                ),
                ExpandableNotifier(
                  controller: widget.vm.panelController,
                  child: ExpandablePanel(
                    header: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        color: AppTheme.colors.background,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // {{PanelHeader}}
                          Expanded(
                            flex: 5,
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              // onTap: () async {
                              //   panelExpandController.toggle();
                              // },
                              child: Container(
                                width: 100,
                                height: 60,
                                decoration: BoxDecoration(),
                                child: PanelHeader(
                                  widget.vm,
                                  widget.vm.panelController,
                                ),
                              ),
                            ),
                          ),

                          // {{directionsButton}}
                          Expanded(
                            flex: 1,
                            child: Container(
                              width: 100,
                              height: 60,
                              decoration: BoxDecoration(),
                              child: DirectionsButton(
                                callbacks.onDirectionSelect,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    collapsed: Container(
                      width: double.infinity,
                      height: 0,
                    ),
                    expanded:
                        // {{PanelInfo}}
                        Container(
                          width: double.infinity,
                          height: MediaQuery.sizeOf(context).height * 0.4,
                          decoration: BoxDecoration(
                            color: AppTheme.colors.background,
                          ),
                          child: PanelInfo(widget.vm,(_){}, (_){}),
                        ),
                    theme: ExpandableThemeData(
                      tapHeaderToExpand: true,
                      tapBodyToExpand: false,
                      tapBodyToCollapse: false,
                      headerAlignment: ExpandablePanelHeaderAlignment.center,
                      hasIcon: false,
                    ),
                  ),
                ),
              ],
            ),

            SafeArea(
              minimum: EdgeInsets.all(10),
              top: true,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 6,
                    // {{SearchBarButton}}
                      child: SearchBarButton(
                        widget.vm.nodeInFocus?.name ?? "search:",
                        callbacks.onSearchBarButtonSelect,
                      ),
                  ),
                  SizedBox(width: Defaults.iconSize + 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
