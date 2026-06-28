import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

enum EdgeLine {
  // view manager classr
  walk(Colors.blueAccent, Defaults.edgeWidth, Defaults.edgeWidth),
  lift(Colors.lightGreen, Defaults.edgeWidth, Defaults.edgeWidth),
  bus(Colors.green, Defaults.edgeWidth, 0),
  highlighted(Defaults.edgeHighlight, Defaults.edgeWidth+2, 0);

  static Map<EdgeType, EdgeLine> map = {
    EdgeType.walk: walk,
    EdgeType.bus: bus,
    EdgeType.waitForBus: bus,
    EdgeType.lift: lift,
    EdgeType.waitForLift: lift,
  };

  static EdgeLine of(Edge edge) {
    return map[edge.edgeType]!;
  }

  final Color color;
  final double width;
  final double gap;

  const EdgeLine(this.color, this.width, this.gap);

  Polyline<Edge> getPolyline(Edge edge, bool onCurrentFloor) {
    return Polyline(
      points: [edge.start.getLatLng(), edge.end.getLatLng()],
      hitValue: edge,
      strokeWidth: width,
      color: color.withAlpha(
        onCurrentFloor ? 255 : (Defaults.otherFloorOpacity * 255).round(),
      ),
      pattern: gap > 0
          ? StrokePattern.dotted(spacingFactor: gap / width)
          : StrokePattern.solid(),
    );
  }

  Widget getIcon() {
    if (gap > 0) {
      // dotted
      return Icon(Icons.more_horiz, color: color, size: Defaults.iconSize);
    } else {
      // solid
      return Icon(Icons.rectangle, color: color, size: Defaults.iconSize);
    }
  }
}
