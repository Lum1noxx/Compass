import 'package:clientapp/defaults.dart';
import 'package:flutter/material.dart';

class GPSMarker extends NodeMarker {
  // current gps location

  static Widget icon() {
    return NodeMarker.circleIcon(Colors.blue, 0, Colors.white, 3);
  }

  const GPSMarker(super.onCurrentFloor, super.onTap, {super.key});

  @override
  Widget makeIcon() {
    return GPSMarker.icon();
  }
}

class NearbyMarker extends NodeMarker {
  // destinations near dropped pin/ gps location

  static Widget icon() {
    return NodeMarker.circleIcon(Colors.red, 0, Colors.transparent, 0);
  }

  const NearbyMarker(super.onCurrentFloor, super.onTap, {super.key});

  @override
  Widget makeIcon() {
    return NearbyMarker.icon();
  }
}

class DroppedMarker extends NodeMarker {
  // dropped pin

  static Widget icon() {
    return NodeMarker.circleIcon(Colors.red, 0, Colors.transparent, 0);
  }

  const DroppedMarker(super.onCurrentFloor, super.onTap, {super.key});

  @override
  Widget makeIcon() {
    return DroppedMarker.icon();
  }
}

class SegmentNodeMarker extends NodeMarker {
  // nodes within segments

  static Widget icon() {
    return NodeMarker.circleIcon(Colors.grey, 0, Colors.transparent, 0);
  }

  const SegmentNodeMarker(super.onCurrentFloor, super.onTap, {super.key});

  @override
  Widget makeIcon() {
    return SegmentNodeMarker.icon();
  }
}

class WaypointMarker extends NodeMarker {
  // nodes between segments

  static Widget icon() {
    return NodeMarker.circleIcon(Colors.red, 0, Colors.transparent, 0);
  }

  const WaypointMarker(super.onCurrentFloor, super.onTap, {super.key});

  @override
  Widget makeIcon() {
    return WaypointMarker.icon();
  }
}

class RouteStartMarker extends NodeMarker {
  // start destination of route

  static Widget icon() {
    return NodeMarker.circleIcon(Defaults.RouteStartColor, 0, Colors.transparent, 0);
  }

  const RouteStartMarker(super.onCurrentFloor, super.onTap, {super.key});

  @override
  Widget makeIcon() {
    return RouteStartMarker.icon();
  }
}

class RouteEndMarker extends NodeMarker {
  // end destination of route

  static Widget icon() {
    return NodeMarker.circleIcon(Defaults.RouteEndColor, 0, Colors.transparent, 0);
  }

  const RouteEndMarker(super.onCurrentFloor, super.onTap, {super.key});

  @override
  Widget makeIcon() {
    return RouteEndMarker.icon();
  }
}

class SelectingMarker extends NodeMarker {
  // selected node/ dest

  static Widget icon() {
    return NodeMarker.circleIcon(Defaults.edgeHighlight, 0, Colors.transparent, 0);
  }

  const SelectingMarker(super.onCurrentFloor, super.onTap, {super.key});

  @override
  Widget makeIcon() {
    return SelectingMarker.icon();
  }
}

abstract class NodeMarker extends StatelessWidget {
  static Widget circleIcon(
    Color color,
    double extraSize,
    Color borderColor,
    double borderSize,
  ) {
    return Container(
      width: Defaults.mapMarkerSize + extraSize,
      height: Defaults.mapMarkerSize + extraSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(
          color: borderSize > 0 ? borderColor : Colors.transparent,
          width: borderSize,
        ),
      ),
    );
  }

  final VoidCallback? onTap;
  final bool onCurrentFloor;

  const NodeMarker(this.onCurrentFloor, this.onTap, {super.key});

  Widget makeIcon();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onCurrentFloor ? onTap : () {},
      child: SizedBox(
        width: Defaults.mapMarkerSize,
        height: Defaults.mapMarkerSize,
        child: Center(
          child: Opacity(
            opacity: onCurrentFloor ? 1 : Defaults.otherFloorOpacity,
            child: makeIcon(),
          ),
        ),
      ),
    );
  }
}

// SizedBox(
//         width: 40,
//         height: 40,
//         child: Center(
//           child: Container(
//             width: highlighted ? 20 : 15,
//             height: highlighted ? 20 : 15,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: hollow ? Colors.transparent : color,
//               border: Border.all(color: color, width: highlighted ? 4 : 2),

//             ),
//           ),
//         ),
//       )
