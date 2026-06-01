import 'package:clientapp/constants.dart';
import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/mainActivity.dart';
import 'package:clientapp/models/directionsModel.dart';
import 'package:clientapp/viewmodels/directionsVM.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class DirectionsPage extends StatefulWidget {

  late final DirectionsVM vm;
  late final void Function() gpsOnClick;
  late final void Function(String) searchbarOnEdit;
  late final void Function(LatLng) pinDropCallback;
  late final void Function() searchbarOnEditComplete;
  late final void Function(String) onFloorNameSelect;
  late final void Function(String) onDestNameSelect;
  late final void Function(bool) onSettingEndChanged;

  DirectionsPage({super.key}) {
    vm = DirectionsVM(DirectionsModel());
    gpsOnClick = () {
      vm.pinDropLatLng(vm.gps?.getLatLng() ?? Defaults.mapPosition);
    };
    searchbarOnEdit = (txt) {
      vm.queryAutocomplete(txt);
    };
    pinDropCallback = (LatLng position) {
      vm.pinDropLatLng(position);
    };
    searchbarOnEditComplete = () {
      vm.searchBarFocusNode.unfocus();
    };
    onFloorNameSelect = (floor) => vm.selectFloor(floor);
    onDestNameSelect = (dest) => vm.setDestByName(dest);
    onSettingEndChanged = (settingEnd) {
      if (settingEnd != vm.settingEnd) {
        vm.toggleSettingEnd();
      }
    };
  }

  @override
  State<StatefulWidget> createState() {
    return _DirectionsPageState();
  }

}

class _DirectionsPageState extends State<DirectionsPage> {

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(flex: 10, child: CampusMap(widget.vm, widget.pinDropCallback)),
      Expanded(flex: 2, child: Row(
        children: [
          Expanded(flex: 7, child: SearchBar(widget.vm, widget.searchbarOnEdit, widget.searchbarOnEditComplete)),
          Expanded(flex: 2, child: FloorPicker(widget.vm, widget.onFloorNameSelect)),
          Expanded(flex: 2, child: IconButton(
            onPressed: widget.gpsOnClick,
            icon: Text("GPS")
          ))
        ])
      ),
      Expanded(flex: 5, child: DestinationList(widget.vm, widget.onDestNameSelect)),
      Expanded(flex: 2, child: ButtonRow(widget.vm, widget.onSettingEndChanged))
    ]);
  }

}

class CampusMap extends StatefulWidget {

  final DirectionsVM vm;
  final void Function(LatLng) pinDropCallback;

  const CampusMap(this.vm, this.pinDropCallback, {super.key});

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
          initialCenter: widget.vm.currentSelection == null ? Defaults.mapPosition : widget.vm.currentSelection.getLatLng(),
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
          MarkerLayer(markers: [
            if (widget.vm.gps != null)
              Marker(point: widget.vm.gps!.getLatLng(),
                child: GPSMarker(onTap: (){},)),
            if (widget.vm.currentSelection is TempDestination)
              Marker(point: widget.vm.currentSelection.getLatLng(),
                child: DroppedPin(onTap: (){},)),
            for (Destination destination in widget.vm.nearbyDestinations)
              Marker(point: destination.getLatLng(),
                child: NearbyMarker(onTap: () => widget.vm.setDest(destination),)),
            for (Edge edge in widget.vm.mapPath) // all start nodes
              Marker(point: edge.start.getLatLng(),
                child: PathNodeMarker(onTap: () => widget.vm.selectNode(edge.start),)),
            if (widget.vm.mapPath.isNotEmpty) // final end node
              Marker(point: widget.vm.mapPath.last.end.getLatLng(), 
                child: PathNodeMarker(onTap: () => widget.vm.selectNode(widget.vm.mapPath.last.end))),
            if (widget.vm.mapStartDest != null) // start destination
              Marker(point: widget.vm.mapStartDest!.getLatLng(),
                child: PathStartMarker(onTap: () => widget.vm.setDest(widget.vm.mapStartDest!),)),
            if (widget.vm.mapEndDest != null) // end destination
              Marker(point: widget.vm.mapEndDest!.getLatLng(),
                child: PathEndMarker(onTap: () => widget.vm.setDest(widget.vm.mapEndDest!))),
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

class GPSMarker extends MapMarker {
  const GPSMarker({super.onTap}) : super(hollow:  false, color: Colors.brown, highlighted:  false);
}

class NearbyMarker extends MapMarker {
  const NearbyMarker({super.onTap}) : super(hollow:  true, color:  Colors.orange, highlighted:  false);
}

class DroppedPin extends MapMarker { /// maybe we dont really want this
  const DroppedPin({super.onTap}) : super(hollow:  false, color:  Colors.purple, highlighted:  false);
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


class SearchBar extends StatelessWidget {

  final DirectionsVM vm;
  final void Function(String) onChangeCallback;
  final void Function() onEditingComplete;

  SearchBar(this.vm, this.onChangeCallback, this.onEditingComplete, {super.key}){
    vm.searchBarFocusNode.addListener((){
      if (vm.searchBarFocusNode.hasFocus) {
        vm.searchBarController.selection = TextSelection(baseOffset: 0, extentOffset: vm.searchBarController.text.length);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Enter location:"
      ),
      focusNode: vm.searchBarFocusNode,
      controller: vm.searchBarController,
      onChanged: onChangeCallback,
      selectAllOnFocus: true,
      enableInteractiveSelection: true,
      onEditingComplete: onEditingComplete,
      );
  }

}

class FloorPicker extends StatefulWidget {

  final DirectionsVM vm;
  final void Function(String) onFloorNameSelect;

  const FloorPicker(this.vm, this.onFloorNameSelect, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _FloorPickerState();
  }

}

class _FloorPickerState extends State<FloorPicker> {

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (ctx, child) {
        return DropdownButton<String>(
            value: widget.vm.useSelectedFloor ? Floors.getName(widget.vm.selectedFloor) : "all",
            items: [
              DropdownMenuItem(value: "all", child: Text("all")),
              for (int floor in Constants.floors)
                DropdownMenuItem(value: Floors.getName(floor), child: Text(Floors.getName(floor)))
            ],
            onChanged: (floor) => widget.onFloorNameSelect(floor!)
          );
      }
    );
  }

}

class DestinationList extends StatefulWidget {

  final DirectionsVM vm;
  final void Function(String) onDestNameSelect;

  const DestinationList(this.vm, this.onDestNameSelect, {super.key});

  @override
  State<DestinationList> createState() => _DestinationListState();

}

class _DestinationListState extends State<DestinationList> {

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (ctx, child)=>  ListView(children: [
        for (String dest in widget.vm.autocompleteResults)
          if (widget.vm.newStartDest != null && dest == widget.vm.newStartDest!.name)
            DestinationRow(dest, widget.onDestNameSelect, Colors.yellow)
          else if (widget.vm.newEndDest != null && dest == widget.vm.newEndDest!.name)
            DestinationRow(dest, widget.onDestNameSelect, Colors.yellow)
          else
            DestinationRow(dest, widget.onDestNameSelect)
      ],),
    );
  }

}

class DestinationRow extends StatelessWidget {

  final void Function(String) onPressCallback;
  final String name;
  final Color highlight;

  const DestinationRow(this.name, this.onPressCallback, [this.highlight = Colors.transparent]);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: highlight),
      child: TextButton(onPressed: ()=>onPressCallback(name), child: Text(name)));
  }

}

class ButtonRow extends StatefulWidget {

  final DirectionsVM vm;
  final void Function(bool) onSettingEndChanged; 

  const ButtonRow(this.vm, this.onSettingEndChanged, {super.key});

  @override
  State<ButtonRow> createState() => _ButtonRowState();
}

class _ButtonRowState extends State<ButtonRow> {

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (ctx, child)=>Row(children: [
        Expanded(child: TextButton(
          onPressed: () => widget.onSettingEndChanged(false),
          child: DecoratedBox(
              decoration: BoxDecoration(color: widget.vm.settingEnd ? Colors.blueGrey : Colors.yellow),
              child: Text(widget.vm.newStartDest == null ? "start" : widget.vm.newStartDest!.name)
            )
          )
        ),
        Expanded(child: TextButton(
          onPressed: () => widget.onSettingEndChanged(true),
          child: DecoratedBox(
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