import 'package:clientapp/pages/directions/map/abstractMarker.dart';
import 'package:flutter/material.dart';

class SelectingMarker extends MapMarker {
  const SelectingMarker({super.onTap}) : super(hollow:  true, color:  Colors.pink, highlighted:  true);
}
