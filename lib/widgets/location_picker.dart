import 'dart:convert';
import 'package:billimiut_app/providers/place.dart';
import 'package:billimiut_app/providers/user.dart';
import 'package:dio/dio.dart';
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
  final googleGeocodingApiKey = dotenv.get("GOOGLE_GEOCODING_API_KEY");

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
        zoom: 16.0,
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

  Future<void> _getAddressFromLatLng(Place place) async {
    var baseURL = "https://maps.googleapis.com/maps/api/geocode/json";
    var request =
        "$baseURL?latlng=${place.latitude},${place.longitude}&key=$googleGeocodingApiKey&language=ko";
    var response = await http.get(Uri.parse(request));
    var data = jsonDecode(response.body);
    // print(data['results'][0]['formatted_address']);
    // place.setAddress(data['results'][0]['formatted_address']);
  }

  Future<void> _printAddressFromLatLng(Place place) async {
    var kakaoRESTAPIKey = dotenv.get("KAKAO_REST_API_KEY");

    var baseURL = "https://dapi.kakao.com/v2/local/geo/coord2address.json";

    var request = "$baseURL?x=${place.longitude}&y=${place.latitude}";

    try {
      var response = await http.get(Uri.parse(request), headers: {
        'Authorization': 'KakaoAK $kakaoRESTAPIKey',
      });

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        if (data['documents'].isNotEmpty) {
          var roadAddr = data['documents'][0]['road_address'];
          var jibunAddr = data['documents'][0]['address'];
          var roadAddress =
              roadAddr != null ? roadAddr['address_name'] : 'No road address';
          var jibunAddress = jibunAddr != null
              ? jibunAddr['address_name']
              : 'No jibun address';

          print("Road Address: $roadAddress");
          print("Jibun Address: $jibunAddress");
        } else {
          print("No address found for the given coordinates.");
        }
      } else {
        print("Failed to load address. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Failed to load address: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
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
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    user.latitude,
                    user.longitude,
                  ),
                  zoom: 16.0,
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
                  });
                  place.setLatitude(markerPosition!.latitude);
                  place.setLongitude(markerPosition!.longitude);
                  _getAddressFromLatLng(place);
                  _printAddressFromLatLng(place);
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
