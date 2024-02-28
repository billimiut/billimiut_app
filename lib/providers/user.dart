import 'package:flutter/material.dart';

class User with ChangeNotifier {
  String _userId = "";
  String _nickname = "";
  double _temperature = 0;
  List<dynamic> _location = [];
  double _latitude = 37.29378;
  double _longitude = 126.9764;
  int _borrowCount = 0;
  int _lendCount = 0;
  int _borrowMoney = 0;
  int _lendMoney = 0;
  String _imageUrl = "";
  String _dong = "";
  List<dynamic> _borrowList = [];
  List<dynamic> _lendList = [];
  List<dynamic> _chatList = [];
  List<dynamic> _postsList = [];

  String get userId => _userId;

  String get nickname => _nickname;

  double get temperature => _temperature;

  List<dynamic> get location => _location;

  double get latitude => _latitude;

  double get longitude => _longitude;

  String get imageUrl => _imageUrl;

  String get dong => _dong;

  int get borrowCount => _borrowCount;

  int get lendCount => _lendCount;

  int get borrowMoney => _borrowMoney;

  int get lendMoney => _lendMoney;

  List<dynamic> get borrowList => _borrowList;

  List<dynamic> get lendList => _lendList;

  List<dynamic> get chatList => _chatList;
  List<dynamic> get postsList => _postsList;

  setUserId(String userId) {
    _userId = userId;
    notifyListeners();
  }

  setNickname(String nickname) {
    _nickname = nickname;
    notifyListeners();
  }

  setTemperature(double temperature) {
    _temperature = temperature;
    notifyListeners();
  }

  setImageUrl(String imageUrl) {
    _imageUrl = imageUrl;
    notifyListeners();
  }

  setDong(String dong) {
    _dong = dong;
    notifyListeners();
  }

  setLocation(List<dynamic> location) {
    _location = location;
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

  setBorrowCount(int borrowCount) {
    _borrowCount = borrowCount;
    notifyListeners();
  }

  setLendCount(int lendCount) {
    _lendCount = lendCount;
    notifyListeners();
  }

  setBorrowMoney(int borrowMoney) {
    _borrowMoney = borrowMoney;
    notifyListeners();
  }

  setLendMoney(int lendMoney) {
    _lendMoney = lendMoney;
    notifyListeners();
  }

  setBorrowList(List<dynamic> borrowList) {
    _borrowList = borrowList;
    notifyListeners();
  }

  setLendList(List<dynamic> lendList) {
    _lendList = lendList;
    notifyListeners();
  }

  setChatList(List<dynamic> chatList) {
    _chatList = chatList;
    notifyListeners();
  }

  setPostsList(List<dynamic> postsList) {
    _postsList = postsList;
    notifyListeners();
  }
}
