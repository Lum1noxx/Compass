import 'package:clientapp/data.dart';
import 'package:clientapp/viewmodels/directionsVM.dart';
import 'package:flutter/material.dart';

class RoutePanel extends StatefulWidget {
  
  final DirectionsVM vm;
  final void Function(Node) onNodeSelect;
  final void Function(Segment) onSegmentSelect;
  
  const RoutePanel(this.vm, this.onNodeSelect, this.onSegmentSelect, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _RoutePanelState();
  }

}

class _RoutePanelState extends State<RoutePanel> {
  
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (ctx, child) => Row(children: [
        if (widget.vm.lastRoute.length()>0)
          Expanded(flex: 1, child: RoutePanelList(widget.vm.lastRoute.segments, widget.onNodeSelect, widget.onSegmentSelect)),
        if (widget.vm.itemInFocus is Node)
          Expanded(flex: 1, child: NodeInfo(widget.vm.itemInFocus))
        else if (widget.vm.itemInFocus is Segment)
          Expanded(flex: 1, child: SegmentInfo(widget.vm.itemInFocus))
      ])
    );
  }

}

class RoutePanelToggle extends StatelessWidget {
  
  final void Function() onToggle;
  
  const RoutePanelToggle(this.onToggle, {super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onToggle,
      icon: Text("more")
      );
  }
}

class SegmentInfo extends StatelessWidget {

  final Segment segment;

  const SegmentInfo(this.segment, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(segment.duration.toString());    
  }

}

class NodeInfo extends StatelessWidget {

  final Node node;

  const NodeInfo(this.node, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(node.name);    
  }
  
}


class RoutePanelList extends StatelessWidget {

  final List<Segment> route;
  final void Function(Node) onNodeSelect;
  final void Function(Segment) onSegmentSelect;

  const RoutePanelList(this.route, this.onNodeSelect, this.onSegmentSelect, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        RoutePanelStart(),
        for (Segment segment in route)
          Column(
            children: [
              NodePanelItem(segment.start(), onNodeSelect),
              SegmentPanelItem(segment, onSegmentSelect)
            ],
          ) ,
        NodePanelItem(route.last.end(), onNodeSelect),
        RoutePanelEnd()
      ],
    );
  }

}

class RoutePanelStart extends StatelessWidget {

  const RoutePanelStart({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.red
      ),
      child: Text("start")
    );
  }

}

class RoutePanelEnd extends StatelessWidget {

  const RoutePanelEnd({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.green,
      ),
      child: Text("end")
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
          color: Colors.orange
        ),
        child: Text(node.name),
      )
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
        decoration: BoxDecoration(
          color: Colors.yellow
        ),
        child: Text(segment.edgeType().name),
      )
    );
  }

}


