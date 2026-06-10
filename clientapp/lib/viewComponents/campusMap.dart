import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/viewComponents/parts/floorPicker.dart';
import 'package:clientapp/viewComponents/parts/gpsButton.dart';
import 'package:clientapp/viewComponents/parts/legend.dart';
import 'package:clientapp/viewComponents/parts/legendButton.dart';
import 'package:clientapp/viewComponents/parts/nodeMarkers.dart';
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
  final void Function() onLegendToggle;

  const CampusMap(
    this.vm,
    this.pinDropCallback,
    this.onDestSelect,
    this.onFloorNameSelect,
    this.onGpsSelect,
    this.onLegendToggle, {
    super.key,
  });

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
      builder: (ctx, child) => Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.center,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: Defaults.mapPosition,
                initialZoom: Defaults.mapInitialZoom,
                onTap: (TapPosition tap, LatLng postion) =>
                    widget.pinDropCallback(postion),
              ),
              mapController: widget.vm.mapController,
              children: [
                TileLayer(
                  // urlTemplate: 'assets/map/{z}/{x}/{y}.png', // backup in case OSM screws us over: download and bundle map tiles
                  // tileProvider: AssetTileProvider()
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: "com.compass.clientapp",
                  tileProvider: NetworkTileProvider(
                    cachingProvider:
                        BuiltInMapCachingProvider.getOrCreateInstance(
                          maxCacheSize: 1_000_000_000, // 1 GB is the default
                        ),
                  ),
                ),
                OverlayImageLayer(overlayImages: widget.vm.visibleFloorplans),

                MarkerLayer(
                  markers: [
                    if (widget.vm.gps != null)
                      Marker(
                        point: widget.vm.gps!.getLatLng(),
                        child: GPSMarker(
                          widget.vm.isOnCurrentFloor(widget.vm.gps!),
                          () {},
                        ),
                      ),
                    if (widget.vm.itemInFocus is Destination &&
                        widget.vm.itemInFocus is! TempDestination)
                      Marker(
                        point: widget.vm.itemInFocus!.getLatLng(),
                        child: SelectingMarker(
                          widget.vm.isOnCurrentFloor(widget.vm.itemInFocus),
                          () {},
                        ),
                      ),
                    if (widget.vm.itemInFocus is TempDestination)
                      Marker(
                        point: widget.vm.itemInFocus!.getLatLng(),
                        child: DroppedMarker(
                          widget.vm.isOnCurrentFloor(widget.vm.itemInFocus),
                          () {},
                        ),
                      ),
                    for (Destination destination
                        in widget.vm.nearbyDestinations) // nearby destinations
                      Marker(
                        point: destination.getLatLng(),
                        child: NearbyMarker(
                          widget.vm.isOnCurrentFloor(destination),
                          () => widget.onDestSelect(destination),
                        ),
                      ),
                  ],
                ),

                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                      onTap: () =>
                          launchUrl(Uri.parse('https://openstreetmap.org')),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SafeArea(
            top: true,
            minimum: EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children: [
                  FloorPicker(widget.vm, widget.onFloorNameSelect),
                  GpsButton(widget.onGpsSelect),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            height: Defaults.legendHeight,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: widget.vm.showLegend
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: Defaults.legendWidth,
                          height: Defaults.legendHeight,
                          child: MapLegend(widget.vm),
                        ),
                        LegendButton(widget.onLegendToggle, true),
                      ],
                    )
                  : LegendButton(widget.onLegendToggle, false),
            ),
          ),
        ],
      ),
    );
  }
}
