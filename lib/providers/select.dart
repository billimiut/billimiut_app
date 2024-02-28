import 'package:flutter/material.dart';

class Select with ChangeNotifier {
  int _selectedIndex = -1;
  String _selectedCategory = '카테고리 선택';

  int get selectedIndex => _selectedIndex;
  String get selectedCategory => _selectedCategory;

  setSelectedIndex(int selectedIndex) {
    _selectedIndex = selectedIndex;
    notifyListeners();
  }

  setSelectedCategory(String selectedCategory) {
    _selectedCategory = selectedCategory;
    notifyListeners();
  }
}
