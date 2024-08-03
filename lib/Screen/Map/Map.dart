import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../Helper/Color.dart';
import '../../Helper/Constant.dart';
import '../../Helper/routes.dart';
import '../../Provider/addressProvider.dart';
import '../../widgets/appBar.dart';
import '../Language/languageSettings.dart';
import 'Widget/myMarker.dart';

class Map extends StatefulWidget {
  final double? latitude, longitude;
  final String? from;

  const Map({Key? key, this.latitude, this.longitude, this.from})
      : super(key: key);

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  LatLng? latlong;
  late CameraPosition _cameraPosition;
  GoogleMapController? _controller;
  TextEditingController locationController = TextEditingController();
  Set<Marker> _markers = {};

  Future getCurrentLocation() async {
    List<Placemark> placemark =
        await placemarkFromCoordinates(widget.latitude!, widget.longitude!);

    if (mounted) {
      setState(
        () {
          latlong = LatLng(widget.latitude!, widget.longitude!);

          _cameraPosition = CameraPosition(target: latlong!, zoom: 16.0);

          if (_controller != null) {
            _controller!.animateCamera(
              CameraUpdate.newCameraPosition(
                _cameraPosition,
              ),
            );
          }

          var address;
          address = placemark[0].name;
          address = address + ',' + placemark[0].subLocality;
          address = address + ',' + placemark[0].locality;
          address = address + ',' + placemark[0].administrativeArea;
          address = address + ',' + placemark[0].country;
          address = address + ',' + placemark[0].postalCode;

          locationController.text = address;
          _markers.add(
            Marker(
              markerId: const MarkerId('Marker'),
              position: LatLng(
                widget.latitude!,
                widget.longitude!,
              ),
            ),
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();

    _cameraPosition = const CameraPosition(target: LatLng(0, 0), zoom: 10.0);
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          getSimpleAppBar(getTranslated(context, 'CHOOSE_LOCATION'), context),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: [
                  (latlong != null)
                      ? GoogleMap(
                          initialCameraPosition: _cameraPosition,
                          onMapCreated: (GoogleMapController controller) {
                            _controller = (controller);
                            _controller!.animateCamera(
                              CameraUpdate.newCameraPosition(
                                _cameraPosition,
                              ),
                            );
                          },
                          myLocationButtonEnabled: false,
                          minMaxZoomPreference:
                              const MinMaxZoomPreference(0, 16),
                          markers: _markers,
                          onTap: (latLng) {
                            if (mounted) {
                              setState(() {
                                latlong = latLng;
                                // Update the marker's position
                                _markers.clear();
                                myMarker(_markers, latlong!, setState,
                                    locationController);
                              });
                            }
                          },
                          /* markers: myMarker(
                              _markers, latlong!, setState, locationController),
                          onTap: (latLng) {
                            if (mounted) {
                              setState(
                                () {
                                  latlong = latLng;
                                },
                              );
                            }
                          },*/
                        )
                      : const SizedBox(),
                ],
              ),
            ),
            TextField(
              cursorColor: Theme.of(context).colorScheme.black,
              controller: locationController,
              readOnly: true,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                icon: Container(
                  margin: const EdgeInsetsDirectional.only(start: 20, top: 0),
                  width: 10,
                  height: 10,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.green,
                  ),
                ),
                hintText: getTranslated(context, 'pick up'),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsetsDirectional.only(start: 15.0, top: 12.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 25.0),
              child: InkWell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: InkWell(
                        onTap: () {
                          if (widget.from ==
                              getTranslated(context, 'ADDADDRESS')) {
                            context.read<AddressProvider>().latitude =
                                latlong!.latitude.toString();
                            context.read<AddressProvider>().longitude =
                                latlong!.longitude.toString();
                          }
                          Future.delayed(
                            const Duration(milliseconds: 500),
                            () => Routes.pop(context),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(circularBorderRadius5),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [colors.grad1Color, colors.grad2Color],
                              stops: [0, 1],
                            ),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                getTranslated(context, 'UPDATE_LOCATION'),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.white,
                                  fontSize: textFontSize16,
                                  fontFamily: 'ubuntu',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
