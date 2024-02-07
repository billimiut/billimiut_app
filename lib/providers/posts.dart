import 'package:flutter/material.dart';

class Posts with ChangeNotifier {
  List<Map<String, dynamic>> _allPosts = [];

  List<Map<String, dynamic>> get allPosts => _allPosts;

  setPosts(List<Map<String, dynamic>> allPosts) {
    _allPosts = allPosts;
    notifyListeners();
  }
}
