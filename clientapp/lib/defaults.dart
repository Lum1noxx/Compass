import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:latlong2/latlong.dart';

class Defaults {
  static const int autocompleteSize = 10;
  static const int nearbyDestinationsCount = 5;
  static const int nearbyVenuesCount = 10;
  static const double walkingSpeedMetresPerSec = 4 / 3;
  static const double iconSize = 35;
  static const double labelHeight = 12;
  static const double autoTextMin = 6;
  static const double autoTextMax = 72;
  static const Duration venueBookingUnit = Duration(minutes: 30);
  static const double segmentIgnoreThreshold = 0.5;

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
  static const Color RouteStartColor = Color.fromARGB(255, 228, 112, 18);
  static const Color RouteEndColor = Color.fromRGBO(1, 105, 36, 1);
  static const Color edgeHighlight = Colors.purpleAccent;
  static const Color occupiedTimeSlotColor = Colors.redAccent;
  static const Color vacantTimeSlotColor = Colors.greenAccent;
}
