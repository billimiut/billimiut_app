import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';

class LocationPicker extends StatefulWidget {
  const LocationPicker({super.key});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final Completer<GoogleMapController> _controller = Completer();

  void _currentLocation() async {
    final GoogleMapController controller = await _controller.future;
    Location location = Location();
    final currentLocation = await location.getLocation();

    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
        zoom: 18.0,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 300,
      decoration:
          BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: const CameraPosition(
            target: LatLng(
              37.29378,
              126.9764,
            ),
            zoom: 18),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          _currentLocation();
        },
        scrollGesturesEnabled: true,
      ),
    );
  }
}
