import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/viewComponents/parts/floorPicker.dart';
import 'package:clientapp/viewComponents/parts/gpsButton.dart';
import 'package:clientapp/viewmodels/directionsDualVM.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';


class RouteMap extends StatefulWidget {

  final DirectionsDualVM vm;
  final void Function(LatLng) pinDropCallback;
  final void Function(Edge) onEdgeMarkerTap;
  final void Function(String) onFloorNameSelect;
  final void Function() onGpsSelect;

  const RouteMap(this.vm, this.pinDropCallback, this.onEdgeMarkerTap, this.onFloorNameSelect, this.onGpsSelect, {super.key});

  @override
  State<RouteMap> createState() => _RouteMapState();

}

class _RouteMapState extends State<RouteMap> {
  
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
    LayerHitNotifier<Edge> polylineTapValue = ValueNotifier(null);
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (ctx, child)=>Stack(
        children: [
          FlutterMap(
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
              GestureDetector(
                behavior: HitTestBehavior.deferToChild,
                onTap: () {
                  if (polylineTapValue.value == null) {
                    return;
                  }
                  widget.onEdgeMarkerTap(polylineTapValue.value!.hitValues.first);
                },
                child: PolylineLayer(
                  hitNotifier: polylineTapValue,
                  polylines: [
                  if (widget.vm.lastRoute.length() > 2)
                    for (Edge edge in widget.vm.lastRoute.edges.sublist(1, widget.vm.lastRoute.length()-1)) // edges between intermediate nodes 
                      Polyline(
                        points: [
                          edge.start.getLatLng(),
                          edge.end.getLatLng()
                        ],
                        strokeWidth:Defaults.edgeWidth,
                        color: Colors.yellow,
                        hitValue: edge
                        
                      ),
                  if (widget.vm.lastRoute.length() > 0) 
                    ...[
                      Polyline(points: [
                        widget.vm.lastRoute.edges.first.start.getLatLng(),
                        widget.vm.lastRoute.edges.first.end.getLatLng()
                      ],
                        strokeWidth:Defaults.edgeWidth,
                        color: Colors.red,
                        pattern: StrokePattern.dotted(),
                        hitValue: widget.vm.lastRoute.edges.first
                      ),
                      Polyline(points: [
                        widget.vm.lastRoute.edges.last.start.getLatLng(),
                        widget.vm.lastRoute.edges.last.end.getLatLng(),
                      ],
                        strokeWidth:Defaults.edgeWidth,
                        color: Colors.green,
                        pattern: StrokePattern.dotted(),
                        hitValue: widget.vm.lastRoute.edges.last
                      )
                    ]
                ]),
              ),
              MarkerLayer(markers: [
                if (widget.vm.gps != null)
                  Marker(point: widget.vm.gps!.getLatLng(),
                    child: GPSMarker(onTap: (){},)),
                if (widget.vm.itemInFocus is TempDestination)
                  Marker(point: widget.vm.itemInFocus.getLatLng(),
                    child: DroppedMarker(onTap: (){},)),
                for (Destination destination in widget.vm.nearbyDestinations) // nearby destinations
                  Marker(point: destination.getLatLng(),
                    child: NearbyMarker(onTap: () => widget.vm.setDest(destination),)),
                if (widget.vm.lastRoute.length() > 1)
                  for (Edge edge in widget.vm.lastRoute.edges.sublist(1, widget.vm.lastRoute.length())) // all intermediate nodes
                    Marker(point: edge.start.getLatLng(),
                      child: PathNodeMarker(onTap: () => widget.vm.focusItem(edge.start),)),
                if (widget.vm.lastRoute.length()>0) // start destination
                  Marker(point: widget.vm.lastRoute.edges.first.start.getLatLng(),
                    child: PathStartMarker(onTap: () => widget.vm.setDest(widget.vm.lastRoute.start()),)),
                if (widget.vm.lastRoute.length()>0) // end destination
                  Marker(point: widget.vm.lastRoute.edges.last.end.getLatLng(),
                    child: PathEndMarker(onTap: () => widget.vm.setDest(widget.vm.lastRoute.end()))),
                if (widget.vm.newStartDest != null)
                  if (widget.vm.settingEnd)
                    Marker(point: widget.vm.newStartDest!.getLatLng(),
                    child: NewChosenMarker(onTap: () => widget.vm.setDest(widget.vm.newStartDest!)))
                  else
                    Marker(point: widget.vm.newStartDest!.getLatLng(),
                    child: SelectingMarker(onTap: () => widget.vm.setDest(widget.vm.newStartDest!))),
                if (widget.vm.newEndDest != null)
                  if (!widget.vm.settingEnd)
                    Marker(point: widget.vm.newEndDest!.getLatLng(),
                    child: NewChosenMarker(onTap: () => widget.vm.setDest(widget.vm.newEndDest!)))
                  else
                    Marker(point: widget.vm.newEndDest!.getLatLng(),
                    child: SelectingMarker(onTap: () => widget.vm.setDest(widget.vm.newEndDest!)))
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