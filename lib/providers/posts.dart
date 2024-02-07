import 'package:flutter/material.dart';

class Posts with ChangeNotifier {
  List<Map<String, dynamic>> _posts = [];

  List<Map<String, dynamic>> get posts => _posts;

  setPosts(List<Map<String, dynamic>> posts) {
    _posts = posts;
    notifyListeners();
  }
}
