import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/viewComponents/parts/floorPicker.dart';
import 'package:clientapp/viewComponents/parts/gpsButton.dart';
import 'package:clientapp/viewmodels/directionsSingleVM.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';


class CampusMap extends StatefulWidget {

  final DirectionsSingleVM vm;
  final void Function(LatLng) pinDropCallback;
  final void Function(Destination) onDestSelect;
  final void Function(String) onFloorNameSelect;
  final void Function() onGpsSelect;


  const CampusMap(this.vm, this.pinDropCallback, this.onDestSelect, this.onFloorNameSelect, this.onGpsSelect, {super.key});

  @override
  State<CampusMap> createState() => _CampusMapState();

}

class _CampusMapState extends State<CampusMap> {
  
  @override
  Widget build(BuildContext context) {
    // return ListenableBuilder(
    //   listenable: widget.vm,
    //   builder: (ctx, child)=>ListView(children: [
    //   Row(children: [Text("start: "), Text(widget.vm.mapStartDest?.toString()??"none")]),
    //   Row(children: [Text("end: "), Text(widget.vm.mapEndDest?.toString()??"none")]),
    //   for (int i = 0; i < widget.vm.mapPath.length; i++)
    //     Row(children: [Text("step $i: "), Text(widget.vm.mapPath[i].toString())],)
    // ],));
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (ctx, child)=>Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: FlutterMap(
              options: MapOptions(
                initialCenter:Defaults.mapPosition,
                initialZoom: Defaults.mapInitialZoom,
                onTap: (TapPosition tap, LatLng postion) => widget.pinDropCallback(postion),
              ),
              mapController: widget.vm.mapController,
              children: [
                TileLayer(
                  // urlTemplate: 'assets/map/{z}/{x}/{y}.png', // backup in case OSM screws us over: download and bundle map tiles
                  // tileProvider: AssetTileProvider()
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: "com.compass.clientapp",
                  tileProvider: NetworkTileProvider(
                    cachingProvider: BuiltInMapCachingProvider.getOrCreateInstance(
                        maxCacheSize: 1_000_000_000, // 1 GB is the default
                    )
                  )
                ),
                OverlayImageLayer(overlayImages: widget.vm.visibleFloorplans),
               
                MarkerLayer(markers: [
                  if (widget.vm.gps != null)
                    Marker(point: widget.vm.gps!.getLatLng(),
                      child: GPSMarker(onTap: (){},)),
                  if (widget.vm.itemInFocus is Destination && widget.vm.itemInFocus is! TempDestination)
                    Marker(point: widget.vm.itemInFocus!.getLatLng(),
                      child: SelectingMarker(onTap: (){},)),
                  if (widget.vm.itemInFocus is TempDestination)
                    Marker(point: widget.vm.itemInFocus!.getLatLng(),
                      child: DroppedMarker(onTap: (){},)),
                  for (Destination destination in widget.vm.nearbyDestinations) // nearby destinations
                    Marker(point: destination.getLatLng(),
                      child: NearbyMarker(onTap: () => widget.onDestSelect(destination),)),
                ]),
               
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                      onTap: () => launchUrl(Uri.parse('https://openstreetmap.org')),
                    ),
                  ],
                )
              
            ]),
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children: [
                  FloorPicker(widget.vm, widget.onFloorNameSelect),
                  GpsButton(widget.onGpsSelect)
                ],
              ),
            ),
          )

        ],
      ));

  }
}
class GPSMarker extends MapMarker {
  const GPSMarker({super.onTap}) : super(hollow:  false, color: Colors.brown, highlighted:  false);
}

class NearbyMarker extends MapMarker {
  const NearbyMarker({super.onTap}) : super(hollow:  true, color:  Colors.orange, highlighted:  false);
}

class DroppedMarker extends MapMarker { /// maybe we dont really want this
  const DroppedMarker({super.onTap}) : super(hollow:  false, color:  Colors.purple, highlighted:  false);
}

class PathNodeMarker extends MapMarker {
  const PathNodeMarker({super.onTap}) : super(hollow:  false, color:  Colors.orange, highlighted:  false);
}

class PathStartMarker extends MapMarker {
  const PathStartMarker({super.onTap}) : super(hollow:  false, color:  Colors.red, highlighted:  false);
}

class PathEndMarker extends MapMarker {
  const PathEndMarker({super.onTap}) : super(hollow:  false, color:  Colors.green, highlighted:  false);
}

class NewChosenMarker extends MapMarker {
  const NewChosenMarker({super.onTap}) : super(hollow:  true, color:  Colors.pink, highlighted:  false);
}

class SelectingMarker extends MapMarker {
  const SelectingMarker({super.onTap}) : super(hollow:  true, color:  Colors.pink, highlighted:  true);
}


class MapMarker extends StatelessWidget {

  final bool highlighted;
  final bool hollow;
  final Color color;
  final VoidCallback? onTap;

  const MapMarker({
    required this.hollow,
    required this.color,
    required this.highlighted,
    this.onTap,
    super.key
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: Container(
            width: highlighted ? 20 : 15,
            height: highlighted ? 20 : 15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hollow ? Colors.transparent : color,
              border: Border.all(color: color, width: highlighted ? 4 : 2),

            ),
          ),
        ),
      ),
    );
  }
}