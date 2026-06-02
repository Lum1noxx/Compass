import 'package:clientapp/pages/directions/directions.dart';
import 'package:clientapp/pages/directions/map/abstractMarker.dart';
import 'package:flutter/material.dart';

class NearbyMarker extends MapMarker {
  const NearbyMarker({super.onTap}) : super(hollow:  true, color:  Colors.orange, highlighted:  false);
}
