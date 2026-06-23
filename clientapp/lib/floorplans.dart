import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

Floorplans floorplans = Floorplans({
  'com1': {
    -1: OverlayImage(
      imageProvider: AssetImage("assets/floorplans/com1_b1.png"),
      bounds: LatLngBounds(
        LatLng(1.295265106, 103.773374542),
        LatLng(1.294232643, 103.774370164),
      ),
    ),
    1: OverlayImage(
      imageProvider: AssetImage("assets/floorplans/com1_1.png"),
      bounds: LatLngBounds(
        LatLng(1.2942485632382001, 103.7731428476486002),
        LatLng(1.2955539981982001, 103.7743574520326035),
      ),
    ),
    2: OverlayImage(
      imageProvider: AssetImage("assets/floorplans/com1_2.png"),
      bounds: LatLngBounds(
        LatLng(1.295586326, 103.773101261),
        LatLng(1.294042075, 103.774499408),
      ),
    ),
  },
  'com2': {
    1: OverlayImage(
      imageProvider: AssetImage("assets/floorplans/com2_1.png"),
      bounds: LatLngBounds(
        LatLng(1.294828520, 103.773356709),
        LatLng(1.292990442, 103.774729782),
      ),
    ),
  },
  'com3': {
    1: OverlayImage(
      imageProvider: AssetImage("assets/floorplans/com3_1.png"),
      bounds: LatLngBounds(
        LatLng(1.2937783009999999, 103.7735533459999999),
        LatLng(1.2958738430000001, 103.7757558119999999),
      ),
    ),
    2: OverlayImage(
      imageProvider: AssetImage("assets/floorplans/com3_2.png"),
      bounds: LatLngBounds(
        LatLng( 1.295664301, 103.773382061,),
        LatLng( 1.293637396, 103.775665604,)
      ),
    ),
  },
  'com4': {
    2: OverlayImage(
      imageProvider: AssetImage("assets/floorplans/com4_2.png"),
      bounds: LatLngBounds(
        LatLng(1.295496134, 103.775043308),
        LatLng(1.294797331, 103.775860172),
      ),
    ),
    3: OverlayImage(
      imageProvider: AssetImage("assets/floorplans/com4_3.png"),
      bounds: LatLngBounds(
        LatLng(1.295494831, 103.775042363),
        LatLng(1.294802821, 103.775861552),
      ),
    ),
  },
});

class Floorplans {
  final Map<int, List<OverlayImage>> plans = {};

  Floorplans(Map<String, Map<int, OverlayImage>> map) {
    for (Map<int, OverlayImage> subPlans in map.values) {
      for (int floor in subPlans.keys) {
        plans.putIfAbsent(floor, () => []);
        plans[floor]!.add(subPlans[floor]!);
      }
    }
  }

  List<OverlayImage> get(int floor) {
    return plans[floor] ?? [];
  }
}
