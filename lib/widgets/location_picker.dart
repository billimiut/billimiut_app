import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';
import '../widgets/animated_marker.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({Key? key}) : super(key: key);

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final Completer<GoogleMapController> _controller = Completer();
  bool isDragging = false;

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

  void _showInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('이웃과 만날 장소명을 입력해주세요'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('예) 성균관대학교 기숙사 예관 3층 자판기 앞',
                  style: TextStyle(color: Colors.grey[700])),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '장소명',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('확인'),
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
          height: 200,
          width: 300,
          decoration:
              BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
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
                    zoom: 18),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  _currentLocation();
                },
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
                scrollGesturesEnabled: true,
              ),
              AnimatedMarker(
                isMoving: isDragging,
              ),
              Positioned(
                bottom: 10,
                child: ElevatedButton(
                  onPressed: () {
                    _showInputDialog(context);
                  },
                  child: Text('선택 완료'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
