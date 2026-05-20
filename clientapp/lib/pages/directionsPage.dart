import 'package:clientapp/data.dart';
import 'package:clientapp/mainActivity.dart';
import 'package:clientapp/models/directionsModel.dart';
import 'package:clientapp/viewmodels/directionsVM.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class DirectionsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DirectionsPageState(DirectionsVM(DirectionsModel()));
  }
}

class _DirectionsPageState extends State<DirectionsPage> {
  _DirectionsPageState(this.vm);
  DirectionsVM vm;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(flex: 10, child: CampusMap(vm)),
      Expanded(flex: 2, child: SearchBar((txt)=>vm.queryAutocomplete(txt))),
      Expanded(flex: 5, child: DestinationList(vm)),
      Expanded(flex: 2, child: ButtonRow(vm))
    ]);
  }
}

class CampusMap extends StatefulWidget {
  CampusMap(this.vm);
  DirectionsVM vm;
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
      builder: (ctx, child)=>FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(1.2966, 103.7764),
          initialZoom: 14,
        ),
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
          MarkerLayer(markers: [
            for (Edge edge in widget.vm.mapPath) // all start nodes
              Marker(point: edge.start.getLatLng(),
                child: PathNodeMarker()),
            if (widget.vm.mapPath.isNotEmpty) // final end node
              Marker(point: widget.vm.mapPath.last.end.getLatLng(), 
                child: PathNodeMarker()),
            if (widget.vm.mapStartDest != null) // start destination
              Marker(point: widget.vm.mapStartDest!.getLatLng(),
                child: PathStartMarker()),
            if (widget.vm.mapEndDest != null) // end destination
              Marker(point: widget.vm.mapEndDest!.getLatLng(),
                child: PathEndMarker()),
            if (widget.vm.newStartDest != null)
              if (widget.vm.settingEnd)
                Marker(point: widget.vm.newStartDest!.getLatLng(), child: NewChosenMarker())
              else
                Marker(point: widget.vm.newStartDest!.getLatLng(), child: SelectingMarker()),
            if (widget.vm.newEndDest != null)
              if (!widget.vm.settingEnd)
                Marker(point: widget.vm.newEndDest!.getLatLng(), child: NewChosenMarker())
              else
                Marker(point: widget.vm.newEndDest!.getLatLng(), child: SelectingMarker())
          ]),
          PolylineLayer(polylines: [
            for (Edge edge in widget.vm.mapPath) // edges between nodes 
              Polyline(
                points: [
                  edge.start.getLatLng(),
                  edge.end.getLatLng()
                ],
                strokeWidth: 3,
                color: Colors.yellow,
                
              ),
            if (widget.vm.mapPath.isNotEmpty) 
              ...[
                Polyline(points: [
                  widget.vm.mapStartDest!.getLatLng(),
                  widget.vm.mapPath.first.start.getLatLng()
                ],
                  strokeWidth: 3,
                  color: Colors.red,
                  pattern: StrokePattern.dotted()
                ),
                Polyline(points: [
                  widget.vm.mapPath.last.end.getLatLng(),
                  widget.vm.mapEndDest!.getLatLng()
                ],
                  strokeWidth: 3,
                  color: Colors.green,
                  pattern: StrokePattern.dotted()
                )
              ]

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

class PathNodeMarker extends MapMarker {
  const PathNodeMarker() : super(hollow:  false, color:  Colors.orange, highlighted:  false);
}

class PathStartMarker extends MapMarker {
  const PathStartMarker() : super(hollow:  false, color:  Colors.red, highlighted:  false);
}

class PathEndMarker extends MapMarker {
  const PathEndMarker() : super(hollow:  false, color:  Colors.green, highlighted:  false);
}

class NewChosenMarker extends MapMarker {
  const NewChosenMarker() : super(hollow:  true, color:  Colors.pink, highlighted:  false);
}

class SelectingMarker extends MapMarker {
  const SelectingMarker() : super(hollow:  true, color:  Colors.pink, highlighted:  true);
}


class MapMarker extends StatelessWidget {
  const MapMarker({
    required this.hollow,
    required this.color,
    required this.highlighted,
    this.onTap,
  });

  final bool highlighted;
  final bool hollow;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 20,
        height: 20,
        child: Center(
          child: Container(
            width: highlighted ? 15 : 10,
            height: highlighted ? 15 : 10,
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


class SearchBar extends StatelessWidget {
  const SearchBar(this.onChangeCallback);
  final void Function(String) onChangeCallback;
  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChangeCallback,
      selectAllOnFocus: true,
      enableInteractiveSelection: true,
      );
  }
}

class DestinationList extends StatefulWidget {
  DestinationList(this.vm);
  DirectionsVM vm;
  @override
  State<DestinationList> createState() => _DestinationListState();
}

class _DestinationListState extends State<DestinationList> {
  @override
  Widget build(BuildContext context) {
    void Function(String) onPressCallback = (dest) => widget.vm.setDest(dest);
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (ctx, child)=>  ListView(children: [
        for (String dest in widget.vm.autocompleteResults)
          if (widget.vm.newStartDest != null && dest == widget.vm.newStartDest!.name)
            DestinationRow(dest, onPressCallback, Colors.yellow)
          else if (widget.vm.newEndDest != null && dest == widget.vm.newEndDest!.name)
            DestinationRow(dest, onPressCallback, Colors.yellow)
          else
            DestinationRow(dest, onPressCallback)

      ],),
    );
  }
}

class DestinationRow extends StatelessWidget {
  const DestinationRow(this.name, this.onPressCallback, [this.highlight = Colors.transparent]);
  final void Function(String) onPressCallback;
  final String name;
  final Color highlight;
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: highlight),
      child: TextButton(onPressed: ()=>onPressCallback(name), child: Text(name)));
  }
}

class ButtonRow extends StatefulWidget {
  ButtonRow(this.vm);
  DirectionsVM vm;

  @override
  State<ButtonRow> createState() => _ButtonRowState();
}

class _ButtonRowState extends State<ButtonRow> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (ctx, child)=>Row(children: [
        Expanded(child: TextButton(onPressed: (){
          if (widget.vm.settingEnd) {
            widget.vm.toggleSettingEnd();
          }
        }, child: DecoratedBox(
              decoration: BoxDecoration(color: widget.vm.settingEnd ? Colors.blueGrey : Colors.yellow),
              child: Text(widget.vm.newStartDest == null ? "start" : widget.vm.newStartDest!.name)
            )
          )
        ),
        Expanded(child: TextButton(onPressed: (){
          if (!widget.vm.settingEnd) {
            widget.vm.toggleSettingEnd();
          }
        }, child: DecoratedBox(
              decoration: BoxDecoration(color: widget.vm.settingEnd ? Colors.yellow : Colors.blueGrey),
              child: Text(widget.vm.newEndDest == null ? "end" : widget.vm.newEndDest!.name)
            )
          )
        ),
        Expanded(child: TextButton(onPressed: widget.vm.findPath, child: Text("find directions")))
      ],),
    );
  }
}