import 'package:clientapp/defaults.dart';
import 'package:clientapp/pages/venues/callbacks.dart';
import 'package:clientapp/themes.dart';
import 'package:clientapp/viewComponents/campusMap.dart';
import 'package:clientapp/viewComponents/dayOfWeekPicker.dart';
import 'package:clientapp/viewComponents/directionsButton.dart';
import 'package:clientapp/viewComponents/findVenuesButton.dart';
import 'package:clientapp/viewComponents/panelHeader.dart';
import 'package:clientapp/viewComponents/panelInfo.dart';
import 'package:clientapp/viewComponents/panelVenueList.dart';
import 'package:clientapp/viewComponents/searchBarButton.dart';
import 'package:clientapp/viewComponents/timeOfDayPicker.dart';
import 'package:clientapp/viewmodels/venuesVM.dart';
import 'package:expandable/expandable.dart';

import 'package:flutter/material.dart' hide SearchBar;

class VenuesWidget extends StatefulWidget {
  final VenuesVM vm;

  const VenuesWidget(this.vm, {super.key});

  @override
  State<VenuesWidget> createState() => _VenuesWidgetState();
}

class _VenuesWidgetState extends State<VenuesWidget> {
  late VenuesCallbacks callbacks;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    callbacks = VenuesCallbacks(widget.vm);
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
                    callbacks.onVenueSelect,
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
                                  () {},
                                  () {},
                                  () {},
                                ),
                              ),
                            ),
                          ),

                          // {{FindVenuesButton}}
                          FindVenuesButton(callbacks.onFindSelect),
                          SizedBox(width: Defaults.iconSize/2,)
                        ],
                      ),
                    ),
                    collapsed: Container(width: double.infinity, height: 0),
                    expanded:
                        // {{PanelInfo}}
                        Container(
                          width: double.infinity,
                          height: MediaQuery.sizeOf(context).height * 0.4,
                          decoration: BoxDecoration(
                            color: AppTheme.colors.background,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: PanelVenueList(
                                  widget.vm,
                                  callbacks.onVenueSelect,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: PanelInfo(
                                  widget.vm,
                                  (_) {},
                                  (_) {},
                                  callbacks.onFindSelect,
                                  () {},
                                  () {},
                                  () {},
                                ),
                              ),
                            ],
                          ),
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
              child: SizedBox(
                height: 2 * Defaults.iconSize + 30,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            flex: 6,
                            // {{SearchBarButton}}
                            child: SearchBarButton(
                              widget.vm.nodeInFocus?.name ??
                                  "search for location to find vacant rooms nearby:",
                              callbacks.onSearchBarButtonSelect,
                            ),
                          ),
                          SizedBox(width: Defaults.iconSize + 20),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: AppTheme.colors.background,
                              ),

                              child: Row(
                                children: [
                                  Expanded(
                                    child: DayOfWeekPicker(
                                      widget.vm,
                                      callbacks.onDayOfWeekSelect,
                                    ),
                                  ),
                                  Expanded(
                                    child: StartTimePicker(
                                      widget.vm,
                                      callbacks.onStartTimeSelect,
                                    ),
                                  ),
                                  Expanded(
                                    child: EndTimePicker(
                                      widget.vm,
                                      callbacks.onEndTimeSelect,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: Defaults.iconSize + 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
