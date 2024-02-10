import 'dart:convert';
import 'package:billimiut_app/providers/posts.dart';
import 'package:billimiut_app/providers/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:billimiut_app/screens/main_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  Future<void> _pressLogin(String id, String pw, User user, Posts posts) async {
    var apiEndPoint = dotenv.get("API_END_POINT");
    var loginRequest = Uri.parse('$apiEndPoint/login');
    var loginBody = {
      "id": "test1@gmail.com",
      "pw": "111111",
    };
    var loginReponse = await http
        .post(
      loginRequest,
      headers: {'Content-Type': 'application/json'}, // Content-Type 추가
      body: jsonEncode(loginBody),
    )
        .then((value) async {
      var loginData = jsonDecode(value.body);
      user.setNickname(loginData["nickname"]);
      user.setTemperature(loginData["temperature"]);
      user.setLocation(loginData["locations"]);
      user.setBorrowCount(loginData["borrow_count"]);
      user.setLendCount(loginData["lend_count"]);
      user.setTotalMoney(loginData["total_money"]);
      user.setBorrowList(loginData["borrow_list"]);
      user.setLendList(loginData["lend_list"]);
      user.setChatList(loginData["chat_list"]);

      var getPostsRequest = Uri.parse('$apiEndPoint/get_posts');
      var getPostsResponse = await http.get(
        getPostsRequest,
        headers: {'Content-Type': 'application/json'}, // Content-Type 추가
      ).then((value) {
        var getPostsData = jsonDecode(value.body);
        posts.setAllPosts(getPostsData);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }).catchError((e) {
        print("/get_posts error: $e");
      });
    }).catchError((e) {
      print("/login error: $e");
    });
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    Posts posts = Provider.of<Posts>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '빌리미웃',
          style: TextStyle(
              fontFamily: 'Jua',
              fontSize: 35,
              //fontWeight: FontWeight.bold,
              color: Color(0xFFFFB900)), // AppBar의 글씨 색 변경
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // 위젯들을 위쪽으로 정렬
          crossAxisAlignment: CrossAxisAlignment.start, // 위젯들을 왼쪽으로 정렬
          children: <Widget>[
            const Padding(
              padding:
                  EdgeInsets.only(left: 8.0, top: 25.0), // '로그인' 텍스트 왼쪽에 간격 추가
              child: Text(
                '로그인', // '로그인' 텍스트 추가
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8C8C8C)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40.0, // Container의 높이를 40으로 설정
              child: TextField(
                controller: _idController,
                style: const TextStyle(
                    color: Color(0xFFA0A0A0),
                    fontSize: 14), // TextField의 글자색 변경
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 15.0), // 텍스트 필드 세로 패딩 조정
                  hintText: '아이디(이메일)',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40.0, // Container의 높이를 40으로 설정
              child: TextField(
                controller: _pwController,
                style: const TextStyle(
                    color: Color(0xFFA0A0A0),
                    fontSize: 14), // TextField의 글자색 변경
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 15.0), // 텍스트 필드 세로 패딩 조정
                  hintText: '비밀번호',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40, // 로그인 버튼의 높이를 텍스트 필드와 동일하게 조정
              width: double.infinity, // 로그인 버튼의 너비를 가득 채우게 조정
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB900), // 버튼의 글씨 색 변경
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('로그인',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                onPressed: () {
                  _pressLogin(
                      _idController.text, _pwController.text, user, posts);
                },
              ),
            ),
            TextButton(
              child: const Text('아직 회원이 아니신가요? 회원가입',
                  style: TextStyle(color: Color(0xFF8C8C8C))),
              onPressed: () {
                // 회원가입 페이지로 이동하는 로직 작성
              },
            ),
            ElevatedButton(
              child: const Text('카카오톡으로 간편 로그인'),
              onPressed: () {
                // 카카오톡 로그인 로직 작성
              },
            ),
            ElevatedButton(
              child: const Text('구글로 간편 로그인'),
              onPressed: () {
                // 구글 로그인 로직 작성
              },
            ),
          ],
        ),
      ),
    );
  }
}
