import 'package:clientapp/data.dart';
import 'package:clientapp/viewmodels/directionsBaseVM.dart';
import 'package:flutter/material.dart';

class PanelHeader extends StatefulWidget {

  final DirectionsBaseVM vm;

  const PanelHeader(this.vm, {super.key});

  @override
  State<PanelHeader> createState() => _PanelHeaderState();

}

class _PanelHeaderState extends State<PanelHeader> {

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (child, ctx) {
        if (widget.vm.itemInFocus is Node) {
          return NodeHeader(widget.vm.itemInFocus);
        }
        else if (widget.vm.itemInFocus is Segment) {
          return SegmentHeader(widget.vm.itemInFocus);
        } else {
          return Text("nothing selected");
        }
      }
    );
  }

}

class SegmentHeader extends StatelessWidget {

  final Segment segment;

  const SegmentHeader(this.segment, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(segment.duration.toString());    
  }

}

class NodeHeader extends StatelessWidget {

  final Node node;

  const NodeHeader(this.node, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(node.name);    
  }
  
}
