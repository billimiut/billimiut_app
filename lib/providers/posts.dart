import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

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

  List<dynamic> filteredPosts(String keyword) {
    return List.from(_originPosts.where((post) {
      return post['title'].contains(keyword);
    }));
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

  updatePost(dynamic updatedPost) {
    int index = _originPosts
        .indexWhere((post) => post['post_id'] == updatedPost['post_id']);
    if (index != -1) {
      _originPosts[index] = updatedPost;
      setAllPosts(_originPosts);
      notifyListeners();
    } else {
      print("post update error");
    }
  }

  // 새로 추가된 메서드
  void filterPostsByProximity(double userLatitude, double userLongitude, double maxDistance) {
    _allPosts = _originPosts.where((post) {
      double postLatitude = post['map_coordinate']['latitude'];
      double postLongitude = post['map_coordinate']['longitude'];

      // 게시물 위치와 사용자 위치 간의 거리 계산
      double distance = Geolocator.distanceBetween(
        userLatitude,
        userLongitude,
        postLatitude,
        postLongitude,
      );

      return distance <= maxDistance; // 지정된 거리 내에 있는 게시물만 포함
    }).toList();

    notifyListeners();
  }
}
