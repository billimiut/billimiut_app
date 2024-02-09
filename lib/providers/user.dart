import 'package:flutter/material.dart';

class User with ChangeNotifier {
  String _userId = "";
  String _nickname = "";
  double _temperature = 0;
  String _location = "";
  int _borrowCount = 0;
  int _lendCount = 0;
  int _totalMoney = 0;
  List<dynamic> _borrowList = [];
  List<dynamic> _lendList = [];

  String get userId => _userId;

  String get nickname => _nickname;

  double get temperature => _temperature;

  String get location => _location;

  int get borrowCount => _borrowCount;

  int get lendCount => _lendCount;

  int get totalMoney => _totalMoney;

  List<dynamic> get borrowList => _borrowList;

  List<dynamic> get lendList => _lendList;

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

  setLocation(String location) {
    _location = location;
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

  setTotalMoney(int totalMoney) {
    _totalMoney = totalMoney;
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
}
