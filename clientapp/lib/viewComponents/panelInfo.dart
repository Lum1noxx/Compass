import 'package:auto_size_text/auto_size_text.dart';
import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/pages/navigation/callbacks.dart';
import 'package:clientapp/themes.dart';
import 'package:clientapp/util.dart';
import 'package:clientapp/viewComponents/parts/busServicesIcon.dart';
import 'package:clientapp/viewComponents/trackingControls.dart';
import 'package:clientapp/viewmodels/directionsBaseVM.dart';
import 'package:clientapp/viewmodels/navigationVM.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PanelInfo extends StatefulWidget {
  final DirectionsBaseVM vm;
  final void Function(Segment) onSegmentNeighbourSelect;
  final void Function(Node) onNodeSelect;
  final void Function() onVenueSelect;
  final void Function() onTrackingStart;
  final void Function() onTrackingCancel;
  final void Function() onTrackingSubmit;

  const PanelInfo(
    this.vm,
    this.onSegmentNeighbourSelect,
    this.onNodeSelect,
    this.onVenueSelect,
    this.onTrackingStart,
    this.onTrackingCancel,
    this.onTrackingSubmit, {
    super.key,
  });

  @override
  State<PanelInfo> createState() => _PanelInfoState();
}

class _PanelInfoState extends State<PanelInfo> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (child, ctx) {
        Path route;
        Widget panel;
        Segment? segment;
        Node? node;
        if (widget.vm is NavigationVM) {
          route = (widget.vm as NavigationVM).lastRoute;
        } else {
          route = EmptyPath();
        }
        if (widget.vm is NavigationVM) {
          segment = (widget.vm as NavigationVM).segmentInFocus;
        }
        if (widget.vm.nodeInFocus != null) {
          segment ??= route.locate(widget.vm.nodeInFocus);
        }
        node = widget.vm.nodeInFocus;
        if (segment != null) {
          panel = SegmentInfo(
            segment,
            (widget.vm as NavigationVM).tracking,
            widget.onSegmentNeighbourSelect,
            widget.onNodeSelect,
            widget.onTrackingStart,
            widget.onTrackingCancel,
            widget.onTrackingSubmit,
            selectedNode: node,
          );
        } else if (node is Venue) {
          panel = VenueInfo(node);
        } else if (node != null) {
          panel = NodeInfo(node, widget.onVenueSelect);
        } else {
          panel = Container(
            decoration: BoxDecoration(color: AppTheme.colors.background),
            alignment: Alignment.center,
            child: AutoSizeText(
              minFontSize: Defaults.autoTextMin,
              maxFontSize: Defaults.autoTextMax,
              textAlign: TextAlign.center,
              maxLines: 1,
              "nothing currently selected",
              style: TextStyle(color: AppTheme.colors.neutral),
            ),
          );
        }
        return panel;
      },
    );
  }
}

class SegmentInfo extends StatelessWidget {
  final Segment segment;
  final Node? selectedNode;
  final bool tracking;
  final void Function(Segment) onNeighbourSelect;
  final void Function(Node) onNodeSelect;
  final void Function() onTrackingStart;
  final void Function() onTrackingCancel;
  final void Function() onTrackingSubmit;

  const SegmentInfo(
    this.segment,
    this.tracking,
    this.onNeighbourSelect,
    this.onNodeSelect,
    this.onTrackingStart,
    this.onTrackingCancel,
    this.onTrackingSubmit, {
    super.key,
    this.selectedNode,
  });

  @override
  Widget build(BuildContext context) {
    Widget topButton;
    Widget topNode;
    Widget bottomButton;

    if (segment.previous != null) {
      topButton = TextButton(
        onPressed: () => onNeighbourSelect(segment.previous!),
        child: AutoSizeText(
          minFontSize: Defaults.autoTextMin,
          maxFontSize: Defaults.autoTextMax,
          textAlign: TextAlign.center,
          maxLines: 1,
          "previous: ${segment.previous!.edgeType().name}",
          style: TextStyle(color: AppTheme.colors.neutralAccent),
        ),
      );
    } else {
      topButton = AutoSizeText(
        minFontSize: Defaults.autoTextMin,
        maxFontSize: Defaults.autoTextMax,
        textAlign: TextAlign.center,
        maxLines: 1,
        "this is the start",
        style: TextStyle(color: AppTheme.colors.neutralAccent),
      );
    }
    if (segment.next != null) {
      bottomButton = TextButton(
        onPressed: () => onNeighbourSelect(segment.next!),
        child: AutoSizeText(
          minFontSize: Defaults.autoTextMin,
          maxFontSize: Defaults.autoTextMax,
          textAlign: TextAlign.center,
          maxLines: 1,
          "next: ${segment.next!.edgeType().name}",
          style: TextStyle(color: AppTheme.colors.neutralAccent),
        ),
      );
    } else {
      bottomButton = AutoSizeText(
        minFontSize: Defaults.autoTextMin,
        maxFontSize: Defaults.autoTextMax,
        textAlign: TextAlign.center,
        maxLines: 1,
        "you have arrived!",
        style: TextStyle(color: AppTheme.colors.neutralAccent),
      );
    }

    // if (segment.previous != null) {
    //   children.add(
    //     TextButton(
    //       onPressed: () => onNeighbourSelect(segment.previous!),
    //       child: Text(segment.previous!.toString()),
    //     ),
    //   );
    // }
    if (segment.edgeType() == EdgeType.lift) {
      topNode = TextButton(
        onPressed: () => onNodeSelect(segment.start()),
        child: AutoSizeText(
          minFontSize: Defaults.autoTextMin,
          maxFontSize: Defaults.autoTextMax,
          textAlign: TextAlign.center,
          maxLines: 1,
          "from ${Floors.getName(segment.start().coordinate.floor)}: ${segment.start().name}",
          style: TextStyle(color: AppTheme.colors.neutral),
        ),
      );
    } else {
      topNode = TextButton(
        onPressed: () => onNodeSelect(segment.start()),
        child: AutoSizeText(
          minFontSize: Defaults.autoTextMin,
          maxFontSize: Defaults.autoTextMax,
          textAlign: TextAlign.center,
          maxLines: 1,
          "from: ${segment.start().name}",
          style: TextStyle(color: AppTheme.colors.neutral),
        ),
      );
    }
    List<Widget> children = [
      Column(
        children: [
          
          Container(
            decoration: BoxDecoration(
              color: AppTheme.colors.primary,
              borderRadius: BorderRadius.circular(10),
              border: segment.start() == selectedNode
                  ? Border.all(color: Defaults.edgeHighlight, width: 3)
                  : null,
            ),
            child: topNode,
          ),
        ],
      ),
    ];

    if (segment.edgeType() == EdgeType.walk) {
      for (Edge edge in segment.edges) {
        children.add(
          SegmentPanelRowWrapped(
            selected: edge.end == selectedNode,
            child: WalkEdgeRow(edge, onNodeSelect),
          ),
        );
      }
    } else if (segment.edgeType() == EdgeType.bus) {
      for (Edge edge in segment.edges.getRange(0, segment.edges.length)) {
        // exclude waiting edges
        children.add(
          SegmentPanelRowWrapped(
            selected: edge.end == selectedNode,
            child: BusEdgeRow(edge, onNodeSelect),
          ),
        );
      }
    } else {
      // segment.edgeType() == EdgeType.lift
      children.add(
        SegmentPanelRowWrapped(
          selected: segment.end() == selectedNode,
          child: LiftSegmentRow(segment, onNodeSelect),
        ),
      );
    }
    children.add(
      Row(
        children: [
          Spacer(),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppTheme.colors.secondary,
            ),
            margin: EdgeInsets.all(5),
            child: bottomButton,
          ),
        ],
      ),
    );

    return Column(
      children: [
        SizedBox(
            height: Defaults.iconSize,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppTheme.colors.secondary,
                  ),
                  margin: EdgeInsets.all(5),
                  child: topButton,
                ),
                // Expanded(
                //   child: TrackingControls(
                //     tracking,
                //     onTrackingStart,
                //     onTrackingCancel,
                //     onTrackingSubmit,
                //   ),
                // ),
              ],
            ),
          ),
        Expanded(child: ListView(padding: EdgeInsets.all(0), children: children)),
      ],
    );
  }
}

// class WalkSegmentTitle extends StatelessWidget {

// }

class SegmentPanelRowWrapped extends StatelessWidget {
  final Widget child;
  final bool selected;

  const SegmentPanelRowWrapped({
    required this.child,
    required this.selected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 5,
          height: 40,
          decoration: BoxDecoration(
            color: selected ? Defaults.edgeHighlight : AppTheme.colors.neutral,
          ),
        ),
        Row(
          children: [
            Spacer(),
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.colors.primary,
                  borderRadius: BorderRadius.circular(10),
                  border: selected
                      ? Border.all(color: Defaults.edgeHighlight, width: 3)
                      : null,
                ),
                child: child,
              ),
            ),
            Spacer(),
          ],
        ),
      ],
    );
  }
}

class WalkEdgeRow extends StatelessWidget {
  final Edge edge;
  final void Function(Node) onSelect;

  const WalkEdgeRow(this.edge, this.onSelect);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => onSelect(edge.end),
      child: AutoSizeText(
        minFontSize: Defaults.autoTextMin,
        maxFontSize: Defaults.autoTextMax,
        textAlign: TextAlign.center,
        maxLines: 1,
        "${edge.end.name}",
        style: TextStyle(color: AppTheme.colors.neutral),
      ),
    );
  }
}

class BusEdgeRow extends StatelessWidget {
  final Edge edge;
  final void Function(Node) onSelect;

  const BusEdgeRow(this.edge, this.onSelect);

  @override
  Widget build(BuildContext context) {
    Widget icon;
    if (edge is WaitForBusEdge) {
      icon = Column(
        children: [
          SizedBox(
            height: Defaults.iconSize,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Align(
                    alignment: AlignmentGeometry.center,
                    child: AutoSizeText(
                      minFontSize: Defaults.autoTextMin,
                      maxFontSize: Defaults.autoTextMax,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      "wait for busses:",
                      style: TextStyle(color: AppTheme.colors.neutral),
                    ),
                  ),
                ),
                Expanded(
                  child: BusServicesIcon((edge as WaitForBusEdge).services),
                ),
              ],
            ),
          ),
          AutoSizeText(
            minFontSize: Defaults.autoTextMin,
            maxFontSize: Defaults.autoTextMax,
            textAlign: TextAlign.center,
            maxLines: 1,
            "estimated: ~${Util.formatDuration(edge.duration)}",
            style: TextStyle(color: AppTheme.colors.neutral),
          ),
        ],
      );
    } else {
      icon = AutoSizeText(
        minFontSize: Defaults.autoTextMin,
        maxFontSize: Defaults.autoTextMax,
        textAlign: TextAlign.center,
        maxLines: 1,
        "${edge.end.name}",
        style: TextStyle(color: AppTheme.colors.neutral),
      );
    }
    return IconButton(onPressed: () => onSelect(edge.end), icon: icon);
  }
}

class LiftSegmentRow extends StatelessWidget {
  final Segment segment;
  final void Function(Node) onSelect;

  const LiftSegmentRow(this.segment, this.onSelect);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => onSelect(segment.end()),
      child: AutoSizeText(
        minFontSize: Defaults.autoTextMin,
        maxFontSize: Defaults.autoTextMax,
        textAlign: TextAlign.center,
        maxLines: 1,
        "${Floors.getName(segment.end().coordinate.floor)}: ${segment.end().name}",
        style: TextStyle(color: AppTheme.colors.neutral),
      ),
    );
  }
}

class NodeInfo extends StatelessWidget {
  final Node node;
  final void Function() onVenueSelect;

  const NodeInfo(this.node, this.onVenueSelect, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppTheme.colors.background),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AutoSizeText(
            node.toString(),
            maxLines: 2,
            textAlign: TextAlign.center,
            minFontSize: Defaults.autoTextMin,
            maxFontSize: Defaults.autoTextMax,
            style: TextStyle(color: AppTheme.colors.neutral),
          ),
          Row(
            children: [
              Spacer(),
              IconButton(
                onPressed: onVenueSelect,
                icon: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppTheme.colors.primary,
                  ),
                  padding: EdgeInsets.all(5),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.building_2_fill,
                        size: Defaults.iconSize,
                        color: AppTheme.colors.neutral,
                      ),
                      AutoSizeText(
                        minFontSize: Defaults.autoTextMin,
                        maxFontSize: Defaults.autoTextMax,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        "find vacant venues nearby",
                        style: TextStyle(color: AppTheme.colors.neutral),
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}

class VenueInfo extends StatelessWidget {
  final Venue venue;
  const VenueInfo(this.venue, {super.key});

  @override
  Widget build(BuildContext context) {
    TimeOfDay start = venue.start();
    TimeOfDay end = venue.end();
    List<TimeSlotItem> timeSlots = [
      for (
        int hr = start.hour;
        TimeOfDay(hour: hr, minute: 0).isBefore(end);
        hr++
      )
        TimeSlotItem(
          TimeOfDay(hour: hr, minute: 0),
          !venue.isVacantAt(TimeOfDay(hour: hr, minute: 15)),
          !venue.isVacantAt(TimeOfDay(hour: hr, minute: 45)),
        ),
    ];

    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              color: AppTheme.colors.secondary,
            ),
            alignment: AlignmentGeometry.center,
            child: AutoSizeText(
              '${venue.name} availability:',
              maxLines: 1,
              textAlign: TextAlign.center,
              minFontSize: Defaults.autoTextMin,
              maxFontSize: Defaults.autoTextMax,
              style: TextStyle(color: AppTheme.colors.neutral),
            ),
          ),
        ),
        Expanded(
          flex: 10,
          child: ListView(padding: EdgeInsets.all(0), children: timeSlots),
        ),
      ],
    );
  }
}

/// 1h time slot
class TimeSlotItem extends StatelessWidget {
  final bool firstHalfOccupied;
  final bool secondHalfOccupied;
  final TimeOfDay start;
  const TimeSlotItem(
    this.start,
    this.firstHalfOccupied,
    this.secondHalfOccupied,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Defaults.iconSize,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: AppTheme.colors.neutral),
            height: 1,
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    spacing: 0,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: firstHalfOccupied
                                ? Defaults.occupiedTimeSlotColor
                                : Defaults.vacantTimeSlotColor,
                          ),
                          alignment: AlignmentGeometry.center,
                          child: AutoSizeText(
                            firstHalfOccupied ? "occupied" : "vacant",
                            minFontSize: Defaults.autoTextMin,
                            maxFontSize: Defaults.autoTextMax,
                            maxLines: 1,
                            style: TextStyle(color: AppTheme.colors.neutral),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.colors.neutral,
                        ),
                        height: 0.5,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: secondHalfOccupied
                                ? Defaults.occupiedTimeSlotColor
                                : Defaults.vacantTimeSlotColor,
                          ),
                          alignment: AlignmentGeometry.center,
                          child: AutoSizeText(
                            secondHalfOccupied ? "occupied" : "vacant",
                            minFontSize: Defaults.autoTextMin,
                            maxFontSize: Defaults.autoTextMax,
                            maxLines: 1,
                            style: TextStyle(color: AppTheme.colors.neutral),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: AlignmentGeometry.centerLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      spacing: 0,
                      children: [
                        AutoSizeText(
                          start.format(context),
                          maxLines: 1,
                          maxFontSize: Defaults.autoTextMax,
                          minFontSize: Defaults.autoTextMin,
                          style: TextStyle(color: AppTheme.colors.neutral),
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
