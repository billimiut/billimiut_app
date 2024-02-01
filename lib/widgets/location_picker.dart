import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';

class LocationPicker extends StatefulWidget {
  const LocationPicker({Key? key}) : super(key: key);

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final Completer<GoogleMapController> _controller = Completer();
  bool isDragging = false;
  LatLng? markerPosition;

  final TextEditingController _locationController = TextEditingController();

  Future<void> _currentLocation() async {
    Location location = Location();
    final currentLocation = await location.getLocation();

    final GoogleMapController controller = await _controller.future;

    setState(() {
      markerPosition = LatLng(
        currentLocation.latitude!,
        currentLocation.longitude!,
      );
    });

    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: markerPosition!,
        zoom: 18.0,
      ),
    ));
  }

  void _onMapTap(LatLng tappedPosition) {
    setState(() {
      markerPosition = tappedPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 345,
          width: 345,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(45),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(
                    37.29378,
                    126.9764,
                  ),
                  zoom: 18.0,
                ),
                onMapCreated: (GoogleMapController controller) async {
                  _controller.complete(controller);
                  await _currentLocation();
                },
                markers: markerPosition != null
                    ? {
                        Marker(
                          markerId: const MarkerId(''),
                          position: markerPosition!,
                        ),
                      }
                    : {},
                onCameraIdle: () {
                  setState(() {
                    isDragging = false;
                  });
                },
                onCameraMoveStarted: () {
                  setState(() {
                    isDragging = true;
                  });
                },
                onTap: _onMapTap,
                scrollGesturesEnabled: true,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
