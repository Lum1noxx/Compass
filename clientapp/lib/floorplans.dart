import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';



Floorplans floorplans = Floorplans({
  'com3' : {
    1: OverlayImage(
      imageProvider: AssetImage("assets/floorplans/com3_1.tif"),
      bounds: LatLngBounds(
        LatLng( 1.2937783009999999, 103.7735533459999999,),
        LatLng( 1.2958738430000001, 103.7757558119999999,)
      ),
    )
  }
});


class Floorplans {

  final Map<int, List<OverlayImage>> plans = {};

  Floorplans(Map<String,Map<int, OverlayImage>> map) {
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
