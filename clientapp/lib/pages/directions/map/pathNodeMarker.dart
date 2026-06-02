import 'package:clientapp/pages/directions/map/abstractMarker.dart';
import 'package:flutter/material.dart';

class PathNodeMarker extends MapMarker {
  const PathNodeMarker({super.onTap}) : super(hollow:  false, color:  Colors.orange, highlighted:  false);
}
