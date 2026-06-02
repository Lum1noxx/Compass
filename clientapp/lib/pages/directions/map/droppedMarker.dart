import 'package:clientapp/pages/directions/directions.dart';
import 'package:clientapp/pages/directions/map/abstractMarker.dart';
import 'package:flutter/material.dart';

class DroppedMarker extends MapMarker { /// maybe we dont really want this
  const DroppedMarker({super.onTap}) : super(hollow:  false, color:  Colors.purple, highlighted:  false);
}
