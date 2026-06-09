import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/viewComponents/parts/floorPicker.dart';
import 'package:clientapp/viewComponents/parts/gpsButton.dart';
import 'package:clientapp/viewComponents/parts/legend.dart';
import 'package:clientapp/viewComponents/parts/legendButton.dart';
import 'package:clientapp/viewComponents/parts/nodeMarkers.dart';
import 'package:clientapp/viewmodels/directionsDualVM.dart';
import 'package:expandable/expandable.dart';
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
  final void Function() onLegendToggle;

  const RouteMap(this.vm, this.pinDropCallback, this.onEdgeMarkerTap, this.onFloorNameSelect, this.onGpsSelect, this.onLegendToggle, {super.key});

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
        fit: StackFit.expand,
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
                    child: GPSMarker((){},)),
                if (widget.vm.itemInFocus is TempDestination)
                  Marker(point: widget.vm.itemInFocus.getLatLng(),
                    child: DroppedMarker((){},)),
                for (Destination destination in widget.vm.nearbyDestinations) // nearby destinations
                  Marker(point: destination.getLatLng(),
                    child: NearbyMarker(() => widget.vm.setDest(destination),)),
                if (widget.vm.lastRoute.segments.isNotEmpty) // intra-segment nodes
                  for (Segment segment in widget.vm.lastRoute.segments) 
                    if (segment.edges.length > 1)
                      for (Edge edge in segment.edges.getRange(1, segment.edges.length))
                        Marker(point: edge.start.getLatLng(),
                          child: SegmentNodeMarker(() => widget.vm.focusItem(edge.start),)),
                if (widget.vm.lastRoute.segments.length > 1) // inter-segment nodes
                  for (Segment segment in widget.vm.lastRoute.segments.getRange(1, widget.vm.lastRoute.segments.length)) // all intermediate nodes
                    Marker(point: segment.start().getLatLng(),
                      child: WaypointMarker(() => widget.vm.focusItem(segment.start()),)),
                if (widget.vm.lastRoute.length()>0) // start destination
                  Marker(point: widget.vm.lastRoute.edges.first.start.getLatLng(),
                    child: RouteStartMarker(() => widget.vm.setDest(widget.vm.lastRoute.start()),)),
                if (widget.vm.lastRoute.length()>0) // end destination
                  Marker(point: widget.vm.lastRoute.edges.last.end.getLatLng(),
                    child: RouteEndMarker(() => widget.vm.setDest(widget.vm.lastRoute.end()))),
                if (widget.vm.newStartDest != null)
                  Marker(point: widget.vm.newStartDest!.getLatLng(),
                      child: SelectingMarker(() => widget.vm.focusItem(widget.vm.lastRoute.end()))),
                if (widget.vm.newEndDest != null)
                  Marker(point: widget.vm.newEndDest!.getLatLng(),
                      child: SelectingMarker(() => widget.vm.focusItem(widget.vm.lastRoute.end()))),
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
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            height: Defaults.legendHeight,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: widget.vm.showLegend ? Row(children: [
                Container(
                  width: Defaults.legendWidth,
                  child: MapLegend(widget.vm),
                ),
                LegendButton(widget.onLegendToggle, true)
              ],) : LegendButton(widget.onLegendToggle, false)
            ),
          ),
        ],
      ));

  }
}