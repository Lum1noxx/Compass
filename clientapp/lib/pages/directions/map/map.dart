import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/pages/directions/directions.dart';
import 'package:clientapp/pages/directions/map/droppedMarker.dart';
import 'package:clientapp/pages/directions/map/gpsMarker.dart';
import 'package:clientapp/pages/directions/map/nearbyMarker.dart';
import 'package:clientapp/pages/directions/map/newChosenMarker.dart';
import 'package:clientapp/pages/directions/map/pathEndMarker.dart';
import 'package:clientapp/pages/directions/map/pathNodeMarker.dart';
import 'package:clientapp/pages/directions/map/pathStartMarker.dart';
import 'package:clientapp/pages/directions/map/selectingMarker.dart';
import 'package:clientapp/viewmodels/directionsVM.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';


class CampusMap extends StatefulWidget {

  final DirectionsVM vm;
  final void Function(LatLng) pinDropCallback;
  final void Function(Edge) onEdgeMarkerTap;

  const CampusMap(this.vm, this.pinDropCallback, this.onEdgeMarkerTap, {super.key});

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
    LayerHitNotifier<Edge> polylineTapValue = ValueNotifier(null);
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (ctx, child)=>FlutterMap(
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
        
      ]));

  }
}
