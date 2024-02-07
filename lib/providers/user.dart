import 'package:flutter/material.dart';

class User with ChangeNotifier {
  String _nickname = "";
  double _temperature = 0;
  int _totalMoney = 0;
  int _borrowCount = 0;
  int _lendCount = 0;
  List<Map<String, dynamic>> _borrowList = [];
  List<Map<String, dynamic>> _lendList = [];

  String get nickname => _nickname;

  double get temperature => _temperature;

  int get totalMoney => _totalMoney;

  int get borrowCount => _borrowCount;

  int get lendCount => _lendCount;

  List<Map<String, dynamic>> get borrowList => _borrowList;

  List<Map<String, dynamic>> get lendList => _lendList;

  setNickname(String nickname) {
    _nickname = nickname;
    notifyListeners();
  }

  setTemperature(double temperature) {
    _temperature = temperature;
    notifyListeners();
  }

  setTotalMoney(int totalMoney) {
    _totalMoney = totalMoney;
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

  setBorrowList(List<Map<String, dynamic>> borrowList) {
    _borrowList = borrowList;
    notifyListeners();
  }

  setLendList(List<Map<String, dynamic>> lendList) {
    _lendList = lendList;
    notifyListeners();
  }
}
