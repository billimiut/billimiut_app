import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  void _showInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '이웃과 만날 장소명을 입력해주세요.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('예) 성균관대학교 기숙사 예관 3층 자판기 앞',
                  style: TextStyle(
                    color: Colors.grey[700],
                  )),
              const SizedBox(
                height: 20,
              ),
              const TextField(
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '장소명',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 300,
          width: 300,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 1,
            ),
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
              Positioned(
                bottom: 10,
                child: ElevatedButton(
                  onPressed: () {
                    _showInputDialog(context);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xFFFFB900)),
                  ),
                  child: const Text(
                    '선택 완료',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
