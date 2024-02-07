import 'package:flutter/material.dart';

class User with ChangeNotifier {
  String _nickname = "";
  final double _temperature = 0;
  final int _totalMoney = 0;
  final int _borrowCount = 0;
  final int _lendCount = 0;

  String get nickname => _nickname;

  double get temperature => _temperature;

  int get totalMoney => _totalMoney;

  int get borrowCount => _borrowCount;

  int get lendCount => _lendCount;

  void setNickname(String nickname) {
    _nickname = nickname;
    notifyListeners();
  }
}
