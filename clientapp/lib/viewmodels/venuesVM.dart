import 'package:clientapp/data.dart';
import 'package:clientapp/main.dart';
import 'package:clientapp/models/compassModel.dart';
import 'package:clientapp/viewmodels/directionsBaseVM.dart';
import 'package:clientapp/viewmodels/navigationVM.dart';
import 'package:clientapp/viewmodels/pageVM.dart';
import 'package:clientapp/viewmodels/searchVM.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class VenuesVM extends DirectionsBaseVM {
  int vacantDayOfWeek = DateTime.now().weekday - 1;
  TimeOfDay vacantStart = TimeOfDay.fromDateTime(DateTime.now());
  TimeOfDay vacantEnd = TimeOfDay.fromDateTime(
    DateTime.now().add(Duration(hours: 1)),
  );

  VenuesVM(super.navigator, super.model);

  @override
  void callTo(PageVM child) {
    if (child is VenuesVM) {
      child.nodeInFocus = nodeInFocus;
    } else if (child is NavigationVM) {
      child.newStartDest = null;
      if (Globals.destinations.map.containsKey(nodeInFocus?.name)) {
        Globals.destinations.get(nodeInFocus!.name).then((dest) {
          child.newEndDest = dest;
        });
      }
    }
  }

  @override
  void returnFrom(PageVM child) {
    if (child is SearchVM) {
      if (child.selection is Destination) {
        nodeInFocus = child.selection;
      }
    }
  }

  void searchDestination() {
    navTo("search");
    notifyListeners();
  }

  @override
  void pinDropLatLng(LatLng position) {
    TempDestination dest = TempDestination(
      Coordinate(position.latitude, position.longitude, selectedFloor),
    );
    focusItem(dest);
  }

  @override
  void findVenues() async{
    if (nodeInFocus == null) {
      return;
    }
    nearbyDestinations = await model.getVacantVenues(
      nodeInFocus as Destination,
      vacantDayOfWeek,
      Period(vacantStart, vacantEnd),
    );
    notifyListeners();
    openPanel();
  }

  void setDayOfWeek(int dayOfWeek) {
    vacantDayOfWeek = dayOfWeek;
    notifyListeners();
  }

  void setVacantStart(TimeOfDay time) {
    vacantStart = time;
    notifyListeners();
  }

  void setVacantEnd(TimeOfDay time) {
    vacantEnd = time;
    notifyListeners();
  }

}
