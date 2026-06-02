import 'package:clientapp/pages/directions/map/abstractMarker.dart';
import 'package:flutter/material.dart';

class PathEndMarker extends MapMarker {
  const PathEndMarker({super.onTap}) : super(hollow:  false, color:  Colors.green, highlighted:  false);
}
