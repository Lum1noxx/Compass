import 'package:clientapp/data.dart';
import 'package:clientapp/models/compassModel.dart';
import 'package:clientapp/viewmodels/pageVM.dart';
import 'package:latlong2/latlong.dart';

class VenuesVM extends PageVM {

  VenuesVM(super.navigator, this.model);

  late LatLng? pin;

  CompassModel model;


  @override
  void callTo(PageVM child) {
    // TODO: implement callTo
  }

  @override
  void returnFrom(PageVM child) {
    // TODO: implement returnFrom
  }
}