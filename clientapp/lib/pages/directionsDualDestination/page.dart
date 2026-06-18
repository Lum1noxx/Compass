import 'package:clientapp/defaults.dart';
import 'package:clientapp/pages/directionsDualDestination/callbacks.dart';
import 'package:clientapp/themes.dart';
import 'package:clientapp/viewComponents/destSwapButton.dart';
import 'package:clientapp/viewComponents/dualSearchBarButtons.dart';
import 'package:clientapp/viewComponents/findButton.dart';
import 'package:clientapp/viewComponents/panelHeader.dart';
import 'package:clientapp/viewComponents/panelInfo.dart';
import 'package:clientapp/viewComponents/panelRouteList.dart';
import 'package:clientapp/viewComponents/routeFilters.dart';
import 'package:clientapp/viewComponents/routeMap.dart';
import 'package:clientapp/viewmodels/directionsDualVM.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class DirectionsDualDestinationsWidget extends StatefulWidget {
  final DirectionsDualVM vm;

  const DirectionsDualDestinationsWidget(this.vm, {super.key});

  @override
  State<DirectionsDualDestinationsWidget> createState() =>
      _DirectionsDualDestinationsWidgetState();
}

class _DirectionsDualDestinationsWidgetState
    extends State<DirectionsDualDestinationsWidget> {
  late DirectionsDualDestinationsCallbacks callbacks;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    callbacks = DirectionsDualDestinationsCallbacks(widget.vm);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ExpandableController filterExpandController = ExpandableController();

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
                Expanded(
                  flex: 10,
                  child:
                      // {{RouteMap}}}
                      RouteMap(
                        widget.vm,
                        callbacks.onPinDrop,
                        callbacks.onEdgeMarkerTap,
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
                              //   widget.vm.panelController.toggle();
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
                          // {{FindButton}}
                          Expanded(
                            flex: 1,
                            child: Container(
                              width: 100,
                              height: 60,
                              decoration: BoxDecoration(),
                              child: FindButton(callbacks.onFindSelect),
                            ),
                          ),
                        ],
                      ),
                    ),
                    collapsed: Container(width: double.infinity, height: 0),
                    expanded: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.colors.background,
                      ),
                      height: MediaQuery.sizeOf(context).height * 0.4,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // {{PanelRouteList}}
                          Expanded(
                            flex: 1,
                            child: PanelRouteList(
                              widget.vm,
                              callbacks.onRoutePanelNodeSelect,
                              callbacks.onRoutePanelSegmentSelect,
                            ),
                          ),

                          // {{PanelInfo}}
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: MediaQuery.sizeOf(context).height * 0.5,
                              decoration: BoxDecoration(),
                              child: PanelInfo(
                                widget.vm,
                                callbacks.onRoutePanelSegmentSelect,
                                callbacks.onRoutePanelNodeSelect,
                              ),
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
              top: true,
              minimum: EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // {{DualSearchButtons}}
                      Expanded(
                        flex: 6,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 6,
                                child: Container(
                                  decoration: BoxDecoration(),
                                  child: DualSearchBarButtons(
                                    widget.vm,
                                    callbacks.onSearchBarButtonSelect,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: Defaults.iconSize * 2 + 10,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    // {{DestSwapButton}}
                                    DestSwapButton(callbacks.onDestSwap),
                                    ExpandableNotifier(
                                      controller: filterExpandController,
                                      child: ExpandablePanel(
                                        header: Icon(
                                          Icons.filter_alt,
                                          size: Defaults.iconSize,
                                          color: AppTheme.colors.tertiary,
                                        ),
                                        collapsed: Container(
                                          width: 100,
                                          height: 0,
                                          decoration: BoxDecoration(),
                                        ),
                                        expanded:
                                            // {{RouteFilters}}
                                            Container(
                                              height: 100,
                                              decoration: BoxDecoration(),
                                              child: RouteFilters(
                                                widget.vm,
                                                callbacks.onFilterStairsChange,
                                                callbacks
                                                    .onFilterUnshelteredChange,
                                              ),
                                            ),
                                        theme: ExpandableThemeData(
                                          tapHeaderToExpand: true,
                                          tapBodyToExpand: false,
                                          tapBodyToCollapse: false,
                                          headerAlignment:
                                              ExpandablePanelHeaderAlignment
                                                  .center,
                                          hasIcon: false,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: Defaults.iconSize + 20),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
