import 'package:clientapp/data.dart';
import 'package:clientapp/viewmodels/directionsBaseVM.dart';
import 'package:flutter/material.dart';

class PanelInfo extends StatefulWidget {

  final DirectionsBaseVM vm;

  const PanelInfo(this.vm, {super.key});

  @override
  State<PanelInfo> createState() => _PanelInfoState();

}

class _PanelInfoState extends State<PanelInfo> {

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (child, ctx) {
        if (widget.vm.itemInFocus is Node) {
          return NodeInfo(widget.vm.itemInFocus);
        }
        else if (widget.vm.itemInFocus is Segment) {
          return SegmentInfo(widget.vm.itemInFocus);
        } else {
          return Container();
        }
      }
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
