import 'package:clientapp/pages/directions/map/abstractMarker.dart';
import 'package:flutter/material.dart';

class PathStartMarker extends MapMarker {
  const PathStartMarker({super.onTap}) : super(hollow:  false, color:  Colors.red, highlighted:  false);
}
