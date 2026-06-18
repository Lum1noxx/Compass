import 'package:auto_size_text/auto_size_text.dart';
import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/themes.dart';
import 'package:clientapp/viewComponents/parts/edgeLines.dart';
import 'package:clientapp/viewmodels/directionsDualVM.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PanelRouteList extends StatefulWidget {
  final DirectionsDualVM vm;
  final void Function(Node) onNodeSelect;
  final void Function(Segment) onSegmentSelect;

  const PanelRouteList(
    this.vm,
    this.onNodeSelect,
    this.onSegmentSelect, {
    super.key,
  });

  @override
  State<PanelRouteList> createState() => _PanelRouteListState();
}

class _PanelRouteListState extends State<PanelRouteList> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (context, child) {
        Path lastRoute = widget.vm.lastRoute;
        if (lastRoute.isValid()) {
          return Container(
            decoration: BoxDecoration(
              color: AppTheme.colors.primary,
              borderRadius: BorderRadius.circular(10),
            ),

            child: ListView(
              padding: EdgeInsets.all(0),
              children: [
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.colors.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 40,
                  child: AutoSizeText(
                    minFontSize: Defaults.autoTextMin,
                    maxFontSize: Defaults.autoTextMax,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    "Route: ${lastRoute.duration.round()}s",
                    style: TextStyle(color: AppTheme.colors.neutralAccent),
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: NodePanelItem(
                    lastRoute.segments.first.start(),
                    widget.onNodeSelect,
                    widget.vm.nodeInFocus == lastRoute.segments.first.start(),
                    colorOverride: Defaults.RouteStartColor,
                  ),
                ),
                SizedBox(
                  height: 150,
                  child: SegmentPanelItem(
                    lastRoute.segments.first,
                    widget.onSegmentSelect,
                    widget.vm.nodeInFocus == lastRoute.segments.first,
                  ),
                ),
                for (Segment segment in lastRoute.segments.getRange(
                  1,
                  lastRoute.segments.length,
                ))
                  Column(
                    children: [
                      SizedBox(
                        height: 40,
                        child: NodePanelItem(
                          segment.start(),
                          widget.onNodeSelect,
                          widget.vm.nodeInFocus == segment.start(),
                        ),
                      ),
                      SizedBox(
                        height: 150,
                        child: SegmentPanelItem(
                          segment,
                          widget.onSegmentSelect,
                          widget.vm.nodeInFocus == segment,
                        ),
                      ),
                    ],
                  ),
                SizedBox(
                  height: 40,
                  child: NodePanelItem(
                    lastRoute.end(),
                    widget.onNodeSelect,
                    widget.vm.nodeInFocus == lastRoute.end(),
                    colorOverride: Defaults.RouteEndColor,
                  ),
                ),
              ],
            ),
          );
        } else {
          return InvalidPathPanel(lastRoute);
        }
      },
    );
  }
}

class NodePanelItem extends StatelessWidget {
  final Node node;
  final void Function(Node) onSelect;
  final bool selected;
  final Color? colorOverride;

  const NodePanelItem(
    this.node,
    this.onSelect,
    this.selected, {
    this.colorOverride,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => onSelect(node),
      icon: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: colorOverride ?? AppTheme.colors.secondary,
          border: Border.all(
            color: selected ? AppTheme.colors.accent : Colors.transparent,
            width: selected ? 5 : 0,
          ),
        ),
        child: AutoSizeText(
          minFontSize: Defaults.autoTextMin,
          maxFontSize: Defaults.autoTextMax,
          textAlign: TextAlign.center,
          maxLines: 2,
          node.name,
          style: TextStyle(color: AppTheme.colors.neutral),
        ),
      ),
    );
  }
}

class SegmentPanelItem extends StatelessWidget {
  static const Map<EdgeType, IconData> edgeIcons = {
    EdgeType.walk: Icons.directions_walk,
    EdgeType.bus: Icons.directions_bus,
    EdgeType.lift: Icons.elevator,
  };

  final Segment segment;
  final void Function(Segment) onSelect;
  final bool selected;

  const SegmentPanelItem(
    this.segment,
    this.onSelect,
    this.selected, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color color = EdgeLine.of(segment.edges.first).color;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Spacer(),
        IconButton(
          onPressed: () => onSelect(segment),
          icon: Column(
            children: [
              Container(
                height: 10,
                width: 12,
                color: color,
                margin: EdgeInsets.only(bottom: 5),
              ),
              Expanded(
                child: Container(
                  width: 12,
                  decoration: BoxDecoration(color: color),
                ),
              ),
              // Container(
              //   width: 40,
              //   alignment: Alignment.center,
              //   decoration: BoxDecoration(
              //     border: Border.all(color: color, width: selected ? 5 : 1),
              //   ),
              //   child: Text(
              //     segment.edgeType().name,
              //     style: TextStyle(
              //       color: color,
              //       fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              //     ),
              //   ),
              // ),
              Container(
                decoration: BoxDecoration(
                  border: selected ? Border.all(color: color, width: 3) : null,
                ),
                child: Icon(
                  edgeIcons[segment.edgeType()],
                  color: color,
                  size: Defaults.iconSize,
                ),
              ),
              Expanded(
                child: Container(
                  width: 12,
                  decoration: BoxDecoration(color: color),
                ),
              ),
              Icon(
                CupertinoIcons.arrowtriangle_down_fill,
                size: Defaults.iconSize,
                color: color,
              ),
            ],
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 40,
            child: AutoSizeText(
              minFontSize: Defaults.autoTextMin,
              maxFontSize: Defaults.autoTextMax,
              textAlign: TextAlign.center,
              maxLines: 2,
              "${segment.duration.round()}s",
              style: TextStyle(color: AppTheme.colors.neutral),
            ),
          ),
        ),
      ],
    );
  }
}

class InvalidPathPanel extends StatelessWidget {
  final Path path;
  const InvalidPathPanel(this.path, {super.key});

  @override
  Widget build(BuildContext context) {
    String message;
    if (path is EmptyPath) {
      message = "no route to show";
    } else if (path is EdgelessPath) {
      message = "start location coincides with end location";
    } else {
      // path is ImpossiblePath
      message = "unable to find a route - try again with fewer filters";
    }
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.colors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: AutoSizeText(
        minFontSize: Defaults.autoTextMin,
        maxFontSize: Defaults.autoTextMax,
        textAlign: TextAlign.center,
        maxLines: 2,
        message,
        style: TextStyle(color: AppTheme.colors.neutralAccent),
      ),
    );
  }
}
