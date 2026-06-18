import 'package:auto_size_text/auto_size_text.dart';
import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/themes.dart';
import 'package:clientapp/viewmodels/directionsBaseVM.dart';
import 'package:clientapp/viewmodels/directionsDualVM.dart';
import 'package:flutter/material.dart';

class PanelInfo extends StatefulWidget {
  final DirectionsBaseVM vm;
  final void Function(Segment) onSegmentNeighbourSelect;
  final void Function(Node) onNodeSelect;

  const PanelInfo(
    this.vm,
    this.onSegmentNeighbourSelect,
    this.onNodeSelect, {
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
        if (widget.vm is DirectionsDualVM) {
          route = (widget.vm as DirectionsDualVM).lastRoute;
        } else {
          route = EmptyPath();
        }
        if (widget.vm is DirectionsDualVM) {
          segment = (widget.vm as DirectionsDualVM).segmentInFocus;
        }
        if (widget.vm.nodeInFocus != null) {
          segment ??= route.locate(widget.vm.nodeInFocus);
        }
        node = widget.vm.nodeInFocus;
        if (segment != null) {
          panel = SegmentInfo(
            segment,
            widget.onSegmentNeighbourSelect,
            widget.onNodeSelect,
            selectedNode: node,
          );
        } else if (node != null) {
          panel = NodeInfo(node);
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
  final void Function(Segment) onNeighbourSelect;
  final void Function(Node) onNodeSelect;

  const SegmentInfo(
    this.segment,
    this.onNeighbourSelect,
    this.onNodeSelect, {
    super.key,
    this.selectedNode,
  });

  @override
  Widget build(BuildContext context) {
    Widget topButton;
    Widget bottomButton;
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
      topButton = TextButton(
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
      topButton = TextButton(
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
            child: topButton,
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
      for (Edge edge in segment.edges.getRange(1, segment.edges.length - 1)) {
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

    return ListView(padding: EdgeInsets.all(0), children: children);
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
        Container(
          decoration: BoxDecoration(
            color: AppTheme.colors.primary,
            borderRadius: BorderRadius.circular(10),
            border: selected
                ? Border.all(color: Defaults.edgeHighlight, width: 3)
                : null,
          ),
          child: child,
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

  const NodeInfo(this.node, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppTheme.colors.background),
      alignment: Alignment.center,
      child: AutoSizeText(
        node.toString(),
        maxLines: 2,
        textAlign: TextAlign.center,
        minFontSize: Defaults.autoTextMin,
        maxFontSize: Defaults.autoTextMax,
        style: TextStyle(color: AppTheme.colors.neutral),
      ),
    );
  }
}
