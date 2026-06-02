import 'package:flutter/material.dart';

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
