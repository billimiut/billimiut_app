import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Posts with ChangeNotifier {
  List<Map<String, dynamic>> _allPosts = [];

  List<Map<String, dynamic>> get allPosts => _allPosts;
  List<Map<String, dynamic>> getBorrowedPosts() {
    return _allPosts.where((post) => post['borrow'] == true).toList();
  }

  List<Map<String, dynamic>> getLendPosts() {
    return _allPosts.where((post) => post['borrow'] == false).toList();
  }

  setPosts(List<Map<String, dynamic>> allPosts) {
    _allPosts = allPosts;
    notifyListeners();
  }
}
