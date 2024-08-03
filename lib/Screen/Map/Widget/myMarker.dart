import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/*Set<Marker> myMarker(Set<Marker> markers, LatLng latlong,
    StateSetter stateSetter, TextEditingController locationController) {
  markers.clear();

  markers.add(
    Marker(
      markerId: MarkerId(
        Random().nextInt(10000).toString(),
      ),
      position: LatLng(
        latlong.latitude,
        latlong.longitude,
      ),
    ),
  );

  getLocation(latlong, stateSetter, locationController);

  return markers;
}*/


Set<Marker> myMarker(
    Set<Marker> markers,
    LatLng latlong,
    StateSetter stateSetter,
    TextEditingController locationController,
    ) {


  markers.add(
    Marker(
      markerId: MarkerId(
        Random().nextInt(10000).toString(),
      ),
      position: LatLng(
        latlong.latitude,
        latlong.longitude,
      ),
    ),
  );

  getLocation(latlong, stateSetter, locationController);

  return markers;
}


Future<void> getLocation(LatLng latlong, StateSetter stateSetter,
    TextEditingController locationController) async {
  List<Placemark> placemark = await placemarkFromCoordinates(
    latlong.latitude,
    latlong.longitude,
  );

  var address;
  address = placemark[0].name;
  address = address + ',' + placemark[0].subLocality;
  address = address + ',' + placemark[0].locality;
  address = address + ',' + placemark[0].administrativeArea;
  address = address + ',' + placemark[0].country;
  address = address + ',' + placemark[0].postalCode;
  locationController.text = address;
  stateSetter(() {});
}
