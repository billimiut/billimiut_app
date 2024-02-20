import 'dart:convert';
import 'package:billimiut_app/widgets/transaction_section.dart';
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

  Future<void> getMyPosts() async {
    User user = Provider.of<User>(context, listen: false);
    String getMyPosts;
    var apiEndPoint = dotenv.get("API_END_POINT");
    var getMyPostsRequest =
        Uri.parse('$apiEndPoint/get_my_posts?user_id=${user.userId}');

    var getMyPostsresponse = await http.get(
      getMyPostsRequest,
      headers: {'Content-Type': 'application/json'},
    ).then((value) {
      var getMyPostsData = jsonDecode(value.body);
      getMyPostsData = json.decode(utf8.decode(value.bodyBytes));
      print('getpostdata:$getMyPostsData');
      setState(() {
        myPostsList = getMyPostsData;
      });
    }).catchError((e) {
      print("/get_my_posts error: $e");
    });
  }

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
    }
    selectedIndexes.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('삭제 완료하였습니다.'),
      ),
    );
    toggleDeleteMode();
  }

  void deletePostById(String postId) {
    // 삭제 요청을 서버에 보내고 응답을 확인하여 삭제 여부를 처리합니다.
    // 이 부분은 이미 deletePost 함수에 구현되어 있습니다.
    // 필요에 따라 deletePost 함수를 사용하거나 새로운 함수를 추가하여 사용할 수 있습니다.
    // 이 예제에서는 deletePost 함수를 사용합니다.
    deletePost(postId);
  }

  void deletePost(index) async {
    Posts posts = Provider.of<Posts>(context);
    User user = Provider.of<User>(context, listen: false);
    String postId = myPostsList[index]['post_id'];

    // 서버에 삭제 요청 보내기
    var apiEndPoint = dotenv.get("API_END_POINT");
    var deletePostRequest =
        Uri.parse('$apiEndPoint/delete_post?post_id=$postId');

    try {
      var response = await http.delete(
        deletePostRequest,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // 서버에서 삭제가 성공하면 UI에서도 해당 글을 삭제합니다.
        setState(() {
          myPostsList.removeAt(index);
        });
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

    getMyPosts();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('내가 작성한 글'),
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
                                image: loadImage(item["image_url"][0]),
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
                                  Text(
                                    item["name"],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF565656),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      // 수정 아이콘을 눌렀을 때의 동작 구현
                                    },
                                    child: const Icon(
                                      Icons.edit,
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
                                    item["money"] == 0
                                        ? "나눔"
                                        : "${item["money"]}원",
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
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
