import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/viewmodels/directionsDualVM.dart';
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
        return ListView(
          children: [
            RoutePanelStart(),
            for (Segment segment in widget.vm.lastRoute.segments)
              Column(
                children: [
                  NodePanelItem(segment.start(), widget.onNodeSelect),
                  SegmentPanelItem(segment, widget.onSegmentSelect),
                ],
              ),
            if (widget.vm.lastRoute.length() > 0)
              NodePanelItem(widget.vm.lastRoute.end(), widget.onNodeSelect),
            RoutePanelEnd(),
          ],
        );
      },
    );
  }
}

class RoutePanelStart extends StatelessWidget {
  const RoutePanelStart({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Defaults.RouteStartColor),
      child: Text("start"),
    );
  }
}

class RoutePanelEnd extends StatelessWidget {
  const RoutePanelEnd({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Defaults.RouteEndColor),
      child: Text("end"),
    );
  }
}

class NodePanelItem extends StatelessWidget {
  final Node node;
  final void Function(Node) onSelect;

  const NodePanelItem(this.node, this.onSelect, {super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => onSelect(node),
      icon: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.orange,
        ),
        child: Text(node.name),
      ),
    );
  }
}

class SegmentPanelItem extends StatelessWidget {
  final Segment segment;
  final void Function(Segment) onSelect;

  const SegmentPanelItem(this.segment, this.onSelect, {super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => onSelect(segment),
      icon: DecoratedBox(
        decoration: BoxDecoration(color: Colors.yellow),
        child: Text(segment.edgeType().name),
      ),
    );
  }
}
