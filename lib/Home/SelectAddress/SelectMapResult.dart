import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectMapResult{
  String address;
  LatLng? latLng;

  SelectMapResult({
    this.address = '',
    this.latLng,
  });
}