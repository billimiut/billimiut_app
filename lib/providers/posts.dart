import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class Posts with ChangeNotifier {
  List<dynamic> _originPosts = []; // 원본 게시물 리스트
  List<dynamic> _allPosts = [];
  List<dynamic> _nearbyPosts = [];

  List<dynamic> get originPosts => _originPosts; // 원본 게시물 리스트 반환
  List<dynamic> get allPosts => _allPosts;
  List<dynamic> get nearbyPosts => _nearbyPosts; // 근처 게시물 리스트 반환

  void setOriginPosts(List<dynamic> posts, double userLatitude,
      double userLongitude, double maxDistance) {
    _originPosts = posts;
    filterPostsByProximity(
        userLatitude, userLongitude, maxDistance); // 근처 게시물 필터링
    setAllPosts(_nearbyPosts); // 필터링된 게시물을 _allPosts에 설정
  }

  void setAllPosts(List<dynamic> allPosts) {
    _allPosts = List.from(allPosts); // 새로운 리스트를 생성하여 _allPosts에 할당
    notifyListeners();
  }

  void changeOriginPosts(int index, String key, dynamic value) {
    originPosts[index][key] = value;
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
    setAllPosts(_nearbyPosts);
    notifyListeners();
  }

  deleteOriginPost(dynamic postId) {
    _originPosts.removeWhere((post) => post['post_id'] == postId);
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

  // 특정 거리 이내의 게시글만 불러오는 함수
  void filterPostsByProximity(
      double userLatitude, double userLongitude, double maxDistance) {
    _nearbyPosts = _originPosts.where((post) {
      double postLatitude = post['map_coordinate']['latitude'];
      double postLongitude = post['map_coordinate']['longitude'];

      // 게시물 위치와 사용자 위치 간의 거리 계산
      double distance = Geolocator.distanceBetween(
        userLatitude,
        userLongitude,
        postLatitude,
        postLongitude,
      );
      post['distance'] = distance.round();
      return distance <= maxDistance; // 지정된 거리 내에 있는 게시물만 포함
    }).toList();

    notifyListeners();
  }

  void sortPostsByDistance() {
    _allPosts = _nearbyPosts;
    _allPosts.sort((a, b) => a['distance'].compareTo(b['distance']));
    _allPosts.forEach((post) {
      print(post['distance']);
      print(post['detail_address']);
    });
    setAllPosts(_allPosts);
    notifyListeners(); // UI 갱신
  }
}
