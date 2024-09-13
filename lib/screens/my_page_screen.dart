import 'package:billimiut_app/providers/user.dart';
import 'package:billimiut_app/widgets/profile_card.dart';
import 'package:billimiut_app/widgets/transaction_section.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  void initState() {
    super.initState();
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

  // API에서 유저의 포스트를 가져오는 함수
  Future<List<dynamic>> fetchPostsByUser(String userId, bool borrow, String status) async {
    try {

      var apiEndPoint = dotenv.get("API_END_POINT");
      final response = await http.get(
        Uri.parse('$apiEndPoint/post/personal/$userId?borrow=$borrow&status=$status'),
      );
      final body = utf8.decode(response.bodyBytes); // UTF-8로 디코딩

      if (response.statusCode == 200) {
        return jsonDecode(body);
      } else {
        throw Exception('포스트 로드 실패');
      }
    } catch (e) {
      print("오류: $e");
      return [];
    }
  }

  // 두 번의 API 호출을 통해 데이터를 각각 가져옴
  Future<List<dynamic>> fetchAllPostsByUser(String userId, bool borrow) async {
    try {
      List<dynamic> posts = [];

      // "빌림중" 상태 데이터를 가져옴
      List<dynamic> postsBorrowing = await fetchPostsByUser(userId, borrow, '빌림중');
      // "종료" 상태 데이터를 가져옴
      List<dynamic> postsEnded = await fetchPostsByUser(userId, borrow, '종료');

      // 두 리스트를 결합
      posts.addAll(postsBorrowing);
      posts.addAll(postsEnded);

      return posts;
    } catch (e) {
      print("오류: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(
          user.nickname,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF565656),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              size: 24,
            ),
            onPressed: () {
              // 버튼이 눌렸을 때 수행할 동작 작성
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              ProfileCard(
                profileImage: user.profileImage,
                nickname: user.nickname,
                temperature: user.temperature,
                location: user.dong,
                borrowCount: user.borrowCount,
                lendCount: user.lendCount,
                borrowMoney: user.borrowMoney,
                lendMoney: user.lendMoney,
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    child: const Row(
                      children: [
                        Text(
                          "빌린 내역",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8C8C8C),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FutureBuilder<List<dynamic>>(
                    future: fetchAllPostsByUser(user.uuid, true),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                            child: CircularProgressIndicator()); // 로딩 스피너 표시
                      } else if (snapshot.hasError) {
                        return Center(child: Text('오류: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('게시물이 없습니다.'));
                      } else {
                        var postList = snapshot.data!;

                        return Column(
                          children: postList.asMap().entries.map((entry) {
                            int index = entry.key;
                            var item = entry.value;

                            return item != null
                                ? TransactionItem(
                                    postId: item["post_id"],
                                    imageUrl: (item["image_url"] != null &&
                                            item["image_url"].isNotEmpty)
                                        ? item["image_url"][0]
                                        : "",
                                    location: item["detail_address"] ??
                                        "위치 정보 없음", // 위치 정보
                                    title: item["title"] ?? "제목 없음", // 제목
                                    price: item["price"] ?? "가격 정보 없음", // 가격
                                    startDate: DateFormat('yy-MM-dd HH:mm')
                                        .format(
                                            DateTime.parse(item["start_date"])),
                                    endDate: DateFormat('yy-MM-dd HH:mm')
                                        .format(
                                            DateTime.parse(item["end_date"])),
                                    status: item["status"] ?? "상태 정보 없음", // 상태
                                  )
                                : Container();
                          }).toList(),
                        );
                      }
                    },
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    child: const Row(
                      children: [
                        Text(
                          "빌려준 내역",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8C8C8C),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FutureBuilder<List<dynamic>>(
                    future: fetchAllPostsByUser(user.uuid, false),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                            child: CircularProgressIndicator()); // 로딩 스피너 표시
                      } else if (snapshot.hasError) {
                        return Center(child: Text('오류: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('게시물이 없습니다.'));
                      } else {
                        var postList = snapshot.data!;

                        return Column(
                          children: postList.asMap().entries.map((entry) {
                            int index = entry.key;
                            var item = entry.value;

                            return item != null
                                ? TransactionItem(
                                    postId: item["post_id"],
                                    imageUrl: (item["image_url"] != null &&
                                            item["image_url"].isNotEmpty)
                                        ? item["image_url"][0]
                                        : "",
                                    location: item["detail_address"] ??
                                        "위치 정보 없음", // 위치 정보
                                    title: item["title"] ?? "제목 없음", // 제목
                                    price: item["price"] ?? "가격 정보 없음", // 가격
                                    startDate: DateFormat('yy-MM-dd HH:mm')
                                        .format(
                                            DateTime.parse(item["start_date"])),
                                    endDate: DateFormat('yy-MM-dd HH:mm')
                                        .format(
                                            DateTime.parse(item["end_date"])),
                                    status: item["status"] ?? "상태 정보 없음", // 상태
                                  )
                                : Container();
                          }).toList(),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
