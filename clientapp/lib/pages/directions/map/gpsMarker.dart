import 'package:clientapp/pages/directions/directions.dart';
import 'package:clientapp/pages/directions/map/abstractMarker.dart';
import 'package:flutter/material.dart';

class GPSMarker extends MapMarker {
  const GPSMarker({super.onTap}) : super(hollow:  false, color: Colors.brown, highlighted:  false);
}
