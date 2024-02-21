import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Posts with ChangeNotifier {
  List<dynamic> _originPosts = []; // 원본 게시물 리스트
  List<dynamic> _allPosts = [];

  List<dynamic> get originPosts => _originPosts; // 원본 게시물 리스트 반환
  List<dynamic> get allPosts => _allPosts;

  void setOriginPosts(List<dynamic> posts) {
    _originPosts = posts;
    setAllPosts(posts);
  }

  void setAllPosts(List<dynamic> allPosts) {
    _allPosts = List.from(allPosts); // 새로운 리스트를 생성하여 _allPosts에 할당
    notifyListeners();
  }

  void changeOriginPosts(int index, String key, dynamic value) {
    originPosts[index][key] = value;
    setAllPosts(_originPosts);
    notifyListeners();
  }

  List<dynamic> getBorrowedPosts() {
    return List.from(_originPosts
        .where((post) => post['borrow'] == true)); // 새로운 리스트를 생성하여 반환
  }

  List<dynamic> getLendPosts() {
    return List.from(_originPosts
        .where((post) => post['borrow'] == false)); // 새로운 리스트를 생성하여 반환
  }

  List<dynamic> getEmergencyPosts() {
    return List.from(_originPosts
        .where((post) => post['emergency'] == true)); // 새로운 리스트를 생성하여 반환

    // addAllPosts(dynamic post) {
    //   _allPosts.add(post);
    //   notifyListeners();
  }

  addOriginPosts(dynamic post) {
    _originPosts.add(post);
    setAllPosts(_originPosts);
    notifyListeners();
  }

  deleteOriginPost(dynamic postId) {
    _originPosts.removeWhere((post) => post['post_id'] == postId);
    setAllPosts(_originPosts);
    notifyListeners();
  }
}
