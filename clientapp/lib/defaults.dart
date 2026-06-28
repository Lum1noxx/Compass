import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:latlong2/latlong.dart';

class Defaults {
  static const int autocompleteSize = 10;
  static const int nearbyDestinationsCount = 5;
  static const double walkingSpeedMetresPerSec = 4 / 3;
  static const double iconSize = 35;
  static const double switchSize = 40;
  static const double autoTextMin = 8;
  static const double autoTextMax = 24;

  static const LatLng mapPosition = LatLng(1.2966, 103.7764);
  static const int gpsUpdateThreshold =
      1; // in metres, 0 == update for all movements
  static const double mapInitialZoom = 15;
  static const double mapFocusZoom = 20;
  static const double segmentViewPadding = 80;
  static const double edgeWidth = 5;
  static const double otherFloorOpacity = 0.5;
  static const double mapMarkerSize = 15;
  static const double legendHeight = 200;
  static const double legendWidth = 300;

  // universal colors: must work with all themes
  static const Color RouteStartColor = Colors.orange;
  static const Color RouteEndColor = Colors.greenAccent;
  static const Color edgeHighlight = Colors.purpleAccent;
}
