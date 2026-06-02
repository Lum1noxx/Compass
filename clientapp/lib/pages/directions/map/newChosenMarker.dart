import 'package:clientapp/pages/directions/map/abstractMarker.dart';
import 'package:flutter/material.dart';

class NewChosenMarker extends MapMarker {
  const NewChosenMarker({super.onTap}) : super(hollow:  true, color:  Colors.pink, highlighted:  false);
}
