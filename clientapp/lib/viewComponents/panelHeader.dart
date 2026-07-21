import 'package:auto_size_text/auto_size_text.dart';
import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/themes.dart';
import 'package:clientapp/viewComponents/trackingControls.dart';
import 'package:clientapp/viewmodels/directionsBaseVM.dart';
import 'package:clientapp/viewmodels/navigationVM.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PanelHeader extends StatefulWidget {
  final DirectionsBaseVM vm;
  final ExpandableController controller;
  final void Function() onTrackingCancel;
  final void Function() onTrackingStart;
  final void Function() onTrackingSubmit;

  const PanelHeader(
    this.vm,
    this.controller,
    this.onTrackingStart,
    this.onTrackingCancel,
    this.onTrackingSubmit, {
    super.key,
  });

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
    List<Widget> children = [];
    if (widget.vm is NavigationVM) {
      children.add(
        Expanded(flex: 3, child: ExpandBar(widget.controller.expanded)),
      );
      children.add(
        Expanded(
          flex: 2,
          child: ListenableBuilder(
            listenable: widget.vm,
            builder: (context, child) {
              return TrackingControls(
                (widget.vm as NavigationVM).tracking,
                widget.onTrackingStart,
                widget.onTrackingCancel,
                widget.onTrackingSubmit,
              );
            },
          ),
        ),
      );
    } else {
      children.add(
        Expanded(
          flex: 1,
          child: ListenableBuilder(
            listenable: widget.vm,
            builder: (child, ctx) {
              if (widget.vm.nodeInFocus != null) {
                return NodeHeader(widget.vm.nodeInFocus!);
              } else {
                return SizedBox.shrink();
              }
            },
          ),
        ),
      );
      children.add(
        Expanded(flex: 4, child: ExpandBar(widget.controller.expanded)),
      );
    }
    return Row(children: children);
  }
}

class SegmentHeader extends StatelessWidget {
  final Segment segment;

  const SegmentHeader(this.segment, {super.key});

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      segment.edgeType().name,
      minFontSize: Defaults.autoTextMin,
      maxFontSize: Defaults.autoTextMax,
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
    return AutoSizeText(
      node.name,
      minFontSize: Defaults.autoTextMin,
      maxFontSize: Defaults.autoTextMax,
      maxLines: 2,
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
      margin: EdgeInsets.only(bottom: 20, top: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.colors.primary,
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
