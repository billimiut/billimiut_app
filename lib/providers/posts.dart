import 'package:flutter/material.dart';

class Posts with ChangeNotifier {
  List<dynamic> _allPosts = [];

  List<dynamic> get allPosts => _allPosts;

  setAllPosts(List<dynamic> allPosts) {
    _allPosts = allPosts;
    notifyListeners();
  }
}
