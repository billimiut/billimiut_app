import 'dart:convert';
import 'package:billimiut_app/providers/image_list.dart';
import 'package:billimiut_app/providers/place.dart';
import 'package:billimiut_app/providers/select.dart';
import 'package:billimiut_app/widgets/transaction_section.dart';
import 'package:billimiut_app/screens/post_editing_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:billimiut_app/providers/user.dart';
import 'package:billimiut_app/providers/posts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreen();
}

class _MyPostsScreen extends State<MyPostsScreen> {
  List<dynamic> myPostsList = [];
  Set<int> selectedIndexes = {}; // 선택된 항목의 인덱스를 저장하기 위한 집합
  bool isDeleting = false;

  // 체크박스 토글 함수
  void toggleCheckbox(int index) {
    setState(() {
      if (selectedIndexes.contains(index)) {
        selectedIndexes.remove(index); // 선택 취소
      } else {
        selectedIndexes.add(index); // 선택
      }
    });
  }

  // 삭제 모드 토글 함수
  void toggleDeleteMode() {
    setState(() {
      isDeleting = !isDeleting;
      if (!isDeleting) {
        selectedIndexes.clear(); // 삭제 모드가 아니면 선택 취소
      }
    });
  }

  String loadLocation(String? location) {
    if (location != null && location.isNotEmpty) {
      return location;
    } else {
      return '위치정보 없음';
    }
  }

  ImageProvider<Object> loadImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      Uri dataUri = Uri.parse(imageUrl);
      if (dataUri.scheme == "data") {
        return MemoryImage(base64Decode(dataUri.data!.contentAsString()));
      } else if (dataUri.isAbsolute) {
        return NetworkImage(imageUrl);
      }
    }
    return const AssetImage('assets/no_image.png');
  }

  // 선택된 항목 삭제 함수
  void deleteSelectedPosts() {
    if (selectedIndexes.isEmpty) return;

    List<dynamic> postIds =
        selectedIndexes.map((index) => myPostsList[index]['post_id']).toList();

    for (String postId in postIds) {
      deletePostById(postId);
      Posts posts = Provider.of<Posts>(context, listen: false);
      posts.deleteOriginPost(postId);
    }
    setState(() {});
    selectedIndexes.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('삭제 완료하였습니다.'),
      ),
    );
    toggleDeleteMode();
  }

  void deletePostById(String postId) {
    int index = myPostsList.indexWhere((post) => post['post_id'] == postId);
    if (index != -1) {
      deletePost(index);
    }
  }

  void deletePost(index) async {
    Posts posts = Provider.of<Posts>(context, listen: false);
    User user = Provider.of<User>(context, listen: false);
    String postId = myPostsList[index]['post_id'];

    // 서버에 삭제 요청 보내기
    var apiEndPoint = dotenv.get("API_END_POINT");
    var deletePostRequest = Uri.parse('$apiEndPoint/post/$postId');

    try {
      var response = await http.delete(
        deletePostRequest,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // 서버에서 삭제가 성공하면 UI에서도 해당 글을 삭제합니다.
        await Future.delayed(Duration.zero);
        setState(() {
          myPostsList.removeAt(index);
        });
        posts.deleteOriginPost(postId);
        // 전체 삭제 외에 추가 작업이 필요하다면 여기에 구현합니다.
      } else {
        // 서버에서 삭제가 실패하면 에러를 출력합니다.
        print('Failed to delete post. Error code: ${response.statusCode}');
      }
    } catch (error) {
      // 삭제 요청이 실패하면 에러를 출력합니다.
      print('Failed to delete post. Error: $error');
    }
  }

  @override
  void initState() {
    super.initState();

    //getMyPosts();
  }

  String formatDate(dynamic timestamp) {
    if (timestamp != null) {
      print('timestamp type: ${timestamp.runtimeType}');
      DateTime date;
      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else if (timestamp is String) {
        date = DateTime.parse(timestamp);
      } else {
        return '날짜정보 없음';
      }
      return DateFormat('MM/dd HH:mm').format(date);
    } else {
      return '날짜정보 없음';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categories = [
      '디지털기기',
      '생활가전',
      '가구/인테리어',
      '여성용품',
      '일회용품',
      '생활용품',
      '주방용품',
      '캠핑용품',
      '애완용품',
      '스포츠용품',
      '공부용품',
      '놀이용품',
      '무료나눔',
      '의류',
      '공구',
      '식물',
    ];
    Select select = Provider.of<Select>(context);
    ImageList imageList = Provider.of<ImageList>(context);
    User user = Provider.of<User>(context);
    myPostsList = user.postsList;
    myPostsList.sort((a, b) => b['post_time'].compareTo(a['post_time']));
    print("내가 쓴 글: ${user.postsList.length}");

    Place place = Provider.of<Place>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('내가 쓴 글'),
        actions: [
          if (isDeleting) // 삭제 모드인 경우에만 삭제 버튼을 표시합니다.
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                deleteSelectedPosts(); // 선택된 항목 삭제
              },
            ),
          IconButton(
            icon: Icon(isDeleting
                ? Icons.cancel
                : Icons.delete), // 삭제 모드일 때는 취소 아이콘, 그렇지 않으면 삭제 아이콘
            onPressed: () {
              toggleDeleteMode(); // 삭제 모드 토글
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: myPostsList.asMap().entries.map((entry) {
                int index = entry.key;
                var item = entry.value;
                var addressLengthLimit = 25; // 길이 제한을 원하는 값으로 설정하세요.
                var nameAndAddress = item['detail_address'];
                var address = nameAndAddress.length <= addressLengthLimit
                    ? nameAndAddress
                    : item['detail_address'];

                if (index < myPostsList.length) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 16.0),

                    tileColor: item["status"] == "종료"
                        ? Colors.grey.withOpacity(0.3)
                        : const Color(0xFFF4F4F4),
                    leading: isDeleting
                        ? Checkbox(
                            value: selectedIndexes.contains(index),
                            onChanged: (bool? value) {
                              toggleCheckbox(index);
                            },
                          )
                        : null, // 삭제 모드가 아닐 때는 체크박스를 표시하지 않습니다.

                    title: Row(
                      children: [
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFF4F4F4),
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Image(
                                  image: loadImage(item["image_url"].isNotEmpty
                                      ? item["image_url"][0]
                                      : ""),
                                  width: 60,
                                  height: 60,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 18,
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.zero,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        loadLocation(address).length > 20
                                            ? '${loadLocation(address).substring(0, 20)}...'
                                            : loadLocation(address),
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11.0,
                                          color: Color(0xFF8c8c8c),
                                        ),
                                      ),
                                    ),
                                    item['status'] == '게시'
                                        ? GestureDetector(
                                            onTap: () {
                                              var index = categories
                                                  .indexOf(item['category']);
                                              select.setSelectedIndex(index);
                                              select.setSelectedCategory(
                                                  index != -1
                                                      ? item["category"]
                                                      : "카테고리 선택");
                                              imageList.setSelectedImages([]);
                                              imageList.setImageUrls([]);
                                              place.setLatitude(user.latitude);
                                              place
                                                  .setLongitude(user.longitude);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PostEditingScreen(
                                                    postId: item[
                                                        'post_id'], // 수정할 글의 아이디를 전달
                                                    info: item, // 게시물의 정보를 전달
                                                  ),
                                                ),
                                              );
                                            },
                                            child: const Icon(
                                              Icons.edit,
                                              color: Color(0xFFFFB900),
                                            ),
                                          )
                                        : Text(
                                            item['status'],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFFFB900),
                                            ),
                                          ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  item["title"],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF565656),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Text(
                                      item["price"] == 0
                                          ? "나눔"
                                          : "${item["price"]}원",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF565656),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      formatDate(item["start_date"]),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF565656),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(width: 5),
                                    const Text(
                                      "~",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF565656),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      formatDate(item["end_date"]),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF565656),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Container(); // 인덱스가 범위를 벗어났을 때는 빈 컨테이너를 반환합니다.
                }
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
