import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/themes.dart';
import 'package:clientapp/viewmodels/directionsBaseVM.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PanelHeader extends StatefulWidget {
  final DirectionsBaseVM vm;
  final ExpandableController controller;

  const PanelHeader(this.vm, this.controller, {super.key});

  @override
  State<PanelHeader> createState() => _PanelHeaderState();
}

class _PanelHeaderState extends State<PanelHeader> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: ListenableBuilder(
            listenable: widget.vm,
            builder: (child, ctx) {
              if (widget.vm.itemInFocus is Node) {
                return NodeHeader(widget.vm.itemInFocus);
              } else if (widget.vm.itemInFocus is Segment) {
                return SegmentHeader(widget.vm.itemInFocus);
              } else {
                return SizedBox.shrink();
              }
            },
          ),
        ),
        Expanded(flex: 4, child: ExpandBar(widget.controller.expanded)),
      ],
    );
  }
}

class SegmentHeader extends StatelessWidget {
  final Segment segment;

  const SegmentHeader(this.segment, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      segment.edgeType().name,
      textAlign: TextAlign.center,
      style: TextStyle(color: AppTheme.colors.neutralAccent),
    );
  }
}

class NodeHeader extends StatelessWidget {
  final Node node;

  const NodeHeader(this.node, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      node.name,
      textAlign: TextAlign.center,
      style: TextStyle(color: AppTheme.colors.neutralAccent),
    );
  }
}

class ExpandBar extends StatelessWidget {
  final bool expanded;

  const ExpandBar(this.expanded, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 30, top: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.colors.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: expanded
          ? Icon(
              Icons.arrow_drop_down,
              size: Defaults.iconSize,
              color: AppTheme.colors.neutral,
            )
          : Icon(
              Icons.arrow_drop_up,
              size: Defaults.iconSize,
              color: AppTheme.colors.neutral,
            ),
    );
  }
}
