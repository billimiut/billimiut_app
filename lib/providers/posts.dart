import 'package:flutter/material.dart';

class Posts with ChangeNotifier {
  List<dynamic> _originPosts = []; // 원본 게시물 리스트
  List<dynamic> _mainPosts = []; // 필터링되기 전 기본 리스트
  List<dynamic> _allPosts = [];
  List<dynamic> _nearbyPosts = [];

  List<dynamic> get originPosts => _originPosts; // 원본 게시물 리스트 반환
  List<dynamic> get mainPosts => _mainPosts; // 필터링되기 전 기본 리스트
  List<dynamic> get allPosts => _allPosts;
  List<dynamic> get nearbyPosts => _nearbyPosts; // 근처 게시물 리스트 반환

  void setOriginPosts(List<dynamic> posts) {
    _originPosts = posts[0];
    _nearbyPosts = posts[1];
    _mainPosts = _nearbyPosts;
    setAllPosts(_nearbyPosts); // 필터링된 게시물을 _allPosts에 설정
  }

  void setMainPosts(List<dynamic> posts) {
    _mainPosts = posts;
    setAllPosts(_mainPosts); // 필터링된 게시물을 _allPosts에 설정
  }

  void setAllPosts(List<dynamic> allPosts) {
    _allPosts = List.from(allPosts); // 새로운 리스트를 생성하여 _allPosts에 할당
    print(_allPosts);
    notifyListeners();
  }

  void changeOriginPosts(int index, int index2, String key, dynamic value) {
    originPosts[index][key] = value;
    nearbyPosts[index2][key] = value;
    setAllPosts(_nearbyPosts);
    notifyListeners();
  }

  List<dynamic> getBorrowedPosts() {
    return List.from(_nearbyPosts
        .where((post) => post['borrow'] == true)); // 새로운 리스트를 생성하여 반환
  }

  List<dynamic> getLendPosts() {
    return List.from(_nearbyPosts
        .where((post) => post['borrow'] == false)); // 새로운 리스트를 생성하여 반환
  }

  List<dynamic> getEmergencyPosts() {
    return List.from(_nearbyPosts
        .where((post) => post['emergency'] == true)); // 새로운 리스트를 생성하여 반환

    // addAllPosts(dynamic post) {
    //   _allPosts.add(post);
    //   notifyListeners();
  }

  List<dynamic> filteredPosts(String keyword) {
    return List.from(_nearbyPosts.where((post) {
      return post['title'].contains(keyword);
    }));
  }

  addOriginPosts(dynamic post) {
    _originPosts.add(post);
    _nearbyPosts.add(post);
    setAllPosts(_nearbyPosts);
    notifyListeners();
  }

  deleteOriginPost(dynamic postId) {
    _originPosts.removeWhere((post) => post['post_id'] == postId);
    _nearbyPosts.removeWhere((post) => post['post_id'] == postId);
    setAllPosts(_nearbyPosts);
    notifyListeners();
  }

  updatePost(dynamic updatedPost) {
    int index = _originPosts
        .indexWhere((post) => post['post_id'] == updatedPost['post_id']);
    if (index != -1) {
      _originPosts[index] = updatedPost;
      setAllPosts(_nearbyPosts);
      notifyListeners();
    } else {
      print("post update error");
    }
  }
}
