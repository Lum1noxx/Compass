import 'package:clientapp/data.dart';
import 'package:clientapp/defaults.dart';
import 'package:clientapp/themes.dart';
import 'package:clientapp/viewComponents/parts/edgeLines.dart';
import 'package:clientapp/viewComponents/parts/nodeMarkers.dart';
import 'package:clientapp/viewmodels/directionsBaseVM.dart';
import 'package:clientapp/viewmodels/directionsDualVM.dart';
import 'package:flutter/material.dart';

class MapLegend extends StatefulWidget {
  final DirectionsBaseVM vm;

  const MapLegend(this.vm, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _MapLegendState();
  }
}

class _MapLegendState extends State<MapLegend> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (child, ctx) {
        List<LegendItem> nodes = [
          if (widget.vm.gps != null)
            LegendItem(GPSMarker.icon(), "gps position"),
          if (widget.vm.itemInFocus is TempDestination)
            LegendItem(DroppedMarker.icon(), "dropped pin"),
          if (widget.vm.itemInFocus is Destination)
            LegendItem(SelectingMarker.icon(), "selected place"),
          if (widget.vm.nearbyDestinations.isNotEmpty)
            LegendItem(NearbyMarker.icon(), "nearby places"),
        ];
        if (widget.vm is DirectionsDualVM) {
          if ((widget.vm as DirectionsDualVM).lastRoute.length() > 0) {
            nodes.addAll([
              LegendItem(RouteStartMarker.icon(), "start"),
              LegendItem(RouteEndMarker.icon(), "end"),
              LegendItem(WaypointMarker.icon(), "waypoint"),
            ]);
          }
        }
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.colors.secondary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListView(
            children: [
              Text("Legend"),
              Wrap(
                // markers
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (LegendItem node in nodes)
                    SizedBox(
                      width: Defaults.legendWidth / 2 - 10,
                      height: Defaults.iconSize,
                      child: node,
                    ),
                ],
              ),
              if (widget.vm is DirectionsDualVM)
                if ((widget.vm as DirectionsDualVM).lastRoute.length() > 0)
                  Wrap(
                    // polylines
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (LegendItem item in [
                        LegendItem(EdgeLine.walk.getIcon(), "walk"),
                        LegendItem(EdgeLine.bus.getIcon(), "bus"),
                        LegendItem(EdgeLine.lift.getIcon(), "lift"),
                      ])
                        SizedBox(
                          width: Defaults.legendWidth / 2 - 10,
                          height: Defaults.iconSize,
                          child: item,
                        ),
                    ],
                  ),
            ],
          ),
        );
      },
    );
  }
}

class LegendItem extends StatelessWidget {
  final String label;
  final Widget icon;

  const LegendItem(this.icon, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: Defaults.iconSize,
          height: Defaults.iconSize,
          child: icon,
        ),
        Text(label, style: TextStyle(color: AppTheme.colors.neutral)),
      ],
    );
  }
}
