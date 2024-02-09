import 'dart:convert';
import 'dart:io';

import 'package:billimiut_app/providers/place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'package:provider/provider.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({super.key});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final Completer<GoogleMapController> _controller = Completer();
  bool isDragging = false;
  LatLng? markerPosition;
  final googleGeocodingApiKey = Platform.isAndroid
      ? dotenv.get("GOOGLE_GEOCODING_IOS_API_KEY")
      : dotenv.get("GOOGLE_GEOCODING_IOS_API_KEY");

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
      print(markerPosition?.latitude);
      print(markerPosition?.longitude);
    });
  }

  Future<dynamic> _getAddressFromLatLng(Place place) async {
    var baseURL = "https://maps.googleapis.com/maps/api/geocode/json";
    var request =
        "$baseURL?latlng=${place.latitude},${place.longitude}&key=$googleGeocodingApiKey&language=ko";
    var response = await http.get(Uri.parse(request));
    var data = jsonDecode(response.body);
    print(data);
    print(data['results'][0]['address_components'][1]['long_name']);
  }

  @override
  Widget build(BuildContext context) {
    Place place = Provider.of<Place>(context);
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
                onTap: (LatLng tappedPosition) {
                  setState(() {
                    markerPosition = tappedPosition;
                    print(markerPosition?.latitude);
                    print(markerPosition?.longitude);
                  });
                  place.setLatitude(markerPosition!.latitude);
                  place.setLongitude(markerPosition!.longitude);
                  _getAddressFromLatLng(place);
                },
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
