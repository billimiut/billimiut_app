import 'package:flutter/material.dart';

class Place with ChangeNotifier {
  var _name = "";
  var _address = "";
  double _latitude = 37.29378;
  double _longitude = 126.9764;

  String get name => _name;
  String get address => _address;
  double get latitude => _latitude;
  double get longitude => _longitude;

  setName(String name) {
    _name = name;
    notifyListeners();
  }

  setAddress(String address) {
    _address = address;
    notifyListeners();
  }

  setLatitude(double latitude) {
    _latitude = latitude;
    notifyListeners();
  }

  setLongitude(double longitude) {
    _longitude = longitude;
    notifyListeners();
  }
}
