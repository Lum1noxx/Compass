import 'package:clientapp/data.dart';
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
        if (widget.vm.itemInFocus is Node) {
          node = widget.vm.itemInFocus as Node;
          segment = route.locate(widget.vm.itemInFocus);
        } else if (widget.vm.itemInFocus is Segment) {
          segment = widget.vm.itemInFocus as Segment;
        }
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
            child: Text("nothing currently selected"),
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
    List<Widget> children = [];
    // if (segment.previous != null) {
    //   children.add(
    //     TextButton(
    //       onPressed: () => onNeighbourSelect(segment.previous!),
    //       child: Text(segment.previous!.toString()),
    //     ),
    //   );
    // }
    if (segment.edgeType() == EdgeType.lift) {
      children.add(
        TextButton(
          onPressed: () => onNodeSelect(segment.start()),
          child: Text(
            "from ${Floors.getName(segment.start().coordinate.floor)}: ${segment.start().name}",
          ),
        ),
      );
    } else {
      children.add(
        TextButton(
          onPressed: () => onNodeSelect(segment.start()),
          child: Text("from: ${segment.start().name}"),
        ),
      );
    }

    if (segment.edgeType() == EdgeType.walk) {
      for (Edge edge in segment.edges) {
        children.add(WalkEdgeRow(edge, onNodeSelect, edge.end == selectedNode));
      }
    } else if (segment.edgeType() == EdgeType.bus) {
      for (Edge edge in segment.edges) {
        children.add(BusEdgeRow(edge, onNodeSelect, edge.end == selectedNode));
      }
    } else {
      // segment.edgeType() == EdgeType.lift
      children.add(
        LiftSegmentRow(segment, onNodeSelect, segment.end() == selectedNode),
      );
    }
    if (segment.next != null) {
      children.add(
        TextButton(
          onPressed: () => onNeighbourSelect(segment.next!),
          child: Text("next: ${segment.next!.edgeType().name}"),
        ),
      );
    } else {
      children.add(Text("you have arrived!"));
    }

    return Column(children: children);
  }
}

// class WalkSegmentTitle extends StatelessWidget {

// }

class WalkEdgeRow extends StatelessWidget {
  final Edge edge;
  final bool selected;
  final void Function(Node) onSelect;

  const WalkEdgeRow(this.edge, this.onSelect, this.selected);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: selected
            ? Border.all(color: AppTheme.colors.accent, width: 3)
            : null,
      ),
      child: TextButton(
        onPressed: () => onSelect(edge.end),
        child: Text("${edge.end.name}"),
      ),
    );
  }
}

class BusEdgeRow extends StatelessWidget {
  final Edge edge;
  final bool selected;
  final void Function(Node) onSelect;

  const BusEdgeRow(this.edge, this.onSelect, this.selected);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: selected
            ? Border.all(color: AppTheme.colors.accent, width: 3)
            : null,
      ),
      child: TextButton(
        onPressed: () => onSelect(edge.end),
        child: Text("${edge.end.name}"),
      ),
    );
  }
}

class LiftSegmentRow extends StatelessWidget {
  final Segment segment;
  final bool selected;
  final void Function(Node) onSelect;

  const LiftSegmentRow(this.segment, this.onSelect, this.selected);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: selected
            ? Border.all(color: AppTheme.colors.accent, width: 3)
            : null,
      ),
      child: TextButton(
        onPressed: () => onSelect(segment.end()),
        child: Text(
          "${Floors.getName(segment.end().coordinate.floor)}: ${segment.end().name}",
        ),
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
      child: Text(node.toString()),
    );
  }
}
