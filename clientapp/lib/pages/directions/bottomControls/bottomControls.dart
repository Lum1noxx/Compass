import 'package:clientapp/viewmodels/directionsVM.dart';
import 'package:flutter/material.dart';

class BottomControls extends StatefulWidget {

  final DirectionsVM vm;
  final void Function(bool) onSettingEndChanged; 

  const BottomControls(this.vm, this.onSettingEndChanged, {super.key});

  @override
  State<BottomControls> createState() => _BottomControlsState();
}

class _BottomControlsState extends State<BottomControls> {

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
