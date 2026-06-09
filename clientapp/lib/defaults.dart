import 'package:latlong2/latlong.dart';

class Defaults {
  static int autocompleteSize = 5;
  static int nearbyDestinationsCount = 5;
  static double walkingSpeedMetresPerSec = 4/3;
  static double iconSize = 40;

  static LatLng mapPosition = LatLng(1.2966, 103.7764);
  static int gpsUpdateThreshold = 1; // in metres, 0 == update for all movements
  static double mapInitialZoom = 14.5; 
  static double mapFocusZoom = 18.5; 
  static double segmentViewPadding = 80;
  static double edgeWidth = 5;
  static double mapMarkerSize = 40;
  static double legendHeight = 200;
  static double legendWidth = 300;
}

