import 'package:clientapp/pages/directionsDualDestination/callbacks.dart';
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
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // {{DualSearchButtons}}
                    Expanded(
                      flex: 4,
                      child: Container(
                        decoration: BoxDecoration(
                        ),
                        child: DualSearchBarButtons(widget.vm, callbacks.onSearchBarButtonSelect),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // {{DestSwapButton}}
                          Container(
                            width: 100,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                            ),
                            child: DestSwapButton(callbacks.onDestSwap),
                          ),
                          ExpandableNotifier(
                            controller: filterExpandController,
                            child: ExpandablePanel(
                              header: IconButton(
                                iconSize: 50,
                                icon: Icon(
                                  Icons.filter_alt,
                                  size: 24,
                                ),
                                onPressed: () {
                                  filterExpandController.toggle();
                                },
                              ),
                              collapsed: Container(
                                width: 100,
                                height: 0,
                                decoration: BoxDecoration(
                                ),
                              ),
                              expanded:
                                  // {{RouteFilters}}
                                  Container(
                                height: 100,
                                decoration: BoxDecoration(
                                ),
                                child: RouteFilters(widget.vm, callbacks.onFilterStairsChange, callbacks.onFilterUnshelteredChange),
                              ),
                              theme: ExpandableThemeData(
                                tapHeaderToExpand: true,
                                tapBodyToExpand: false,
                                tapBodyToCollapse: false,
                                headerAlignment:
                                    ExpandablePanelHeaderAlignment.center,
                                hasIcon: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              Expanded(
                flex: 10,
                child: 
                    // {{RouteMap}}}
                    RouteMap(widget.vm, callbacks.onPinDrop, callbacks.onEdgeMarkerTap, callbacks.onFloorNameSelect, callbacks.onGpsSelect),
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

                      // {{FindButton}}
                      Expanded(
                        flex: 2,
                        child: Container(
                          width: 100,
                          height: 50,
                          decoration: BoxDecoration(
                          ),
                          child: FindButton(callbacks.onFindSelect),
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
                  expanded: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // {{PanelRouteList}}
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: 50,
                          height: MediaQuery.sizeOf(context).height * 0.4,
                          decoration: BoxDecoration(
                          ),
                          child: PanelRouteList(widget.vm, callbacks.onRoutePanelNodeSelect, callbacks.onRoutePanelSegmentSelect),
                        ),
                      ),

                      // {{PanelInfo}}
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: 50,
                          height: MediaQuery.sizeOf(context).height * 0.4,
                          decoration: BoxDecoration(
                          ),
                          child: PanelInfo(widget.vm),
                        ),
                      ),
                    ],
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
