import 'package:clientapp/viewmodels/directionsBaseVM.dart';
import 'package:flutter/material.dart';

class MapLegend extends StatefulWidget{

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
    return Container(
      child: Text("legend"),
    );
  }

}
