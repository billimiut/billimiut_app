import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Posts with ChangeNotifier {
  List<dynamic> _allPosts = [];
  List<dynamic> get allPosts => _allPosts;

  List<dynamic> getBorrowedPosts() {
    return _allPosts.where((post) => post['borrow'] == true).toList();
  }

  List<dynamic> getLendPosts() {
    return _allPosts.where((post) => post['borrow'] == false).toList();
  }

  setAllPosts(List<dynamic> allPosts) {
    _allPosts = allPosts;
    notifyListeners();
  }
}
