import 'package:flutter/material.dart';

class User with ChangeNotifier {
  String _uuid = "";
  String _id = "";
  String _nickname = "";
  bool _female = false;
  List<dynamic> _keywords = [];
  String _type = "service";
  double _temperature = 36.5;
  List<dynamic> _location = [];
  double _latitude = 37.29378;
  double _longitude = 126.9764;
  int _borrowCount = 0;
  int _lendCount = 0;
  int _borrowMoney = 0;
  int _lendMoney = 0;
  String _profileImage = "";
  String _dong = "율전동";
  List<dynamic> _borrowList = [];
  List<dynamic> _lendList = [];
  List<dynamic> _chatList = [];
  List<dynamic> _postsList = [];

  String get uuid => _uuid;

  String get id => _id;

  String get nickname => _nickname;

  bool get female => _female;

  List<dynamic> get keywords => _keywords;

  String get type => _type;

  double get temperature => _temperature;

  List<dynamic> get location => _location;

  double get latitude => _latitude;

  double get longitude => _longitude;

  String get profileImage => _profileImage;

  String get dong => _dong;

  int get borrowCount => _borrowCount;

  int get lendCount => _lendCount;

  int get borrowMoney => _borrowMoney;

  int get lendMoney => _lendMoney;

  List<dynamic> get borrowList => _borrowList;

  List<dynamic> get lendList => _lendList;

  List<dynamic> get chatList => _chatList;
  List<dynamic> get postsList => _postsList;

  setUuid(String uuid) {
    _uuid = uuid;
    notifyListeners();
  }

  setId(String id) {
    _id = id;
    notifyListeners();
  }

  setNickname(String nickname) {
    _nickname = nickname;
    notifyListeners();
  }

  setFemale(bool female) {
    _female = female;
    notifyListeners();
  }

  setKeywords(List<dynamic> keywords) {
    _keywords = keywords;
    notifyListeners();
  }

  setType(String type) {
    _type = type;
    notifyListeners();
  }

  setTemperature(double temperature) {
    _temperature = temperature;
    notifyListeners();
  }

  setProfileImage(String profileImage) {
    _profileImage = profileImage;
    notifyListeners();
  }

  setDong(String dong) {
    _dong = dong;
    notifyListeners();
  }

  setLocation(List<dynamic> location) {
    _location = location;
    notifyListeners();
  }

  setLatitude(double latitude) {
    _latitude = latitude;
    notifyListeners();
  }

  setLongitude(double longitude) {
    _longitude = longitude;
    notifyListeners();
  }

  setBorrowCount(int borrowCount) {
    _borrowCount = borrowCount;
    notifyListeners();
  }

  setLendCount(int lendCount) {
    _lendCount = lendCount;
    notifyListeners();
  }

  setBorrowMoney(int borrowMoney) {
    _borrowMoney = borrowMoney;
    notifyListeners();
  }

  setLendMoney(int lendPrice) {
    _lendMoney = lendMoney;
    notifyListeners();
  }

  setBorrowList(List<dynamic> borrowList) {
    _borrowList = borrowList;
    notifyListeners();
  }

  setLendList(List<dynamic> lendList) {
    _lendList = lendList;
    notifyListeners();
  }

  setChatList(List<dynamic> chatList) {
    _chatList = chatList;
    notifyListeners();
  }

  setPostsList(List<dynamic> postsList) {
    _postsList = postsList;
    notifyListeners();
  }

  addPostsList(dynamic newPost) {
    _postsList.add(newPost);
    notifyListeners();
  }

  updatePostsList(dynamic updatedPost) {
    int index = postsList
        .indexWhere((post) => post['post_id'] == updatedPost['post_id']);

    if (index != -1) {
      _postsList[index] = updatedPost;
      notifyListeners();
    } else {
      print("postsList update error");
    }
  }

  void updateChatList(String senderUuid, String postId, String lastMessageTime,
      String lastMessage) {
    // senderUuid와 postId가 일치하는 항목이 있는지 확인
    int index = _chatList.indexWhere((chat) =>
        chat['neighbor_id'] == senderUuid && chat['post_id'] == postId);

    if (index != -1) {
      // 일치하는 항목이 있으면 해당 항목을 업데이트
      print('Found matching chat at index $index, updating it.');
      _chatList[index] = {
        'neighbor_id': senderUuid,
        'post_id': postId,
        'neighbor_nickname': _chatList[index]['neighbor_nickname'],
        'neighbor_profile': _chatList[index]['neighbor_profile'],
        'last_message': lastMessage,
        'last_message_time': lastMessageTime,
      };
    } else {
      // 일치하는 항목이 없으면 새로운 항목을 추가
      print('No matching chat found, adding new entry.');
      _chatList.add({
        'neighbor_id': senderUuid,
        'post_id': postId,
        'neighbor_nickname': 'Unknown', // 필요에 따라 값을 수정
        'neighbor_profile': '', // 필요에 따라 값을 수정
        'last_message': lastMessage,
        'last_message_time': lastMessageTime,
      });
    }

    // 업데이트 후 _chatList 상태를 출력
    print('After update: $_chatList');

    // UI 업데이트를 위해 알림
    notifyListeners();
  }
}
