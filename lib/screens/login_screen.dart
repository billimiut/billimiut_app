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

  Future<void> _testLogin(String id, String pw, User user, Posts posts) async {
    var baseUri = dotenv.get("API_END_POINT");
    var loginUri = Uri.parse('$baseUri/login');
    var loginBody = {
      "id": id,
      "pw": pw,
    };
    var loginResponse = await http.post(
      loginUri,
      headers: {'Content-Type': 'application/json'}, // Content-Type 추가
      body: jsonEncode(loginBody),
    );

    // 응답을 json 형식으로 변환
    var loginResponseData = jsonDecode(loginResponse.body);

    print('서버 응답: $loginResponseData');
    print('message 타입: ${loginResponseData['message'].runtimeType}');

    // 응답으로부터 로그인 성공 여부를 판단. 여기서는 'success' 필드를 확인한다고 가정
    if (loginResponseData['message'] == '1') {
      // 로그인 성공 시 메인 페이지로 이동
      print('로그인 성공: ${loginResponseData['message']}');
      user.setUserId(loginResponseData['login_token']);

      var userInfoUri = Uri.parse('$baseUri/my_info');
      var userInfoBody = {
        "login_token": loginResponseData["login_token"],
      };
      var userInfoResponse = await http.post(
        userInfoUri,
        headers: {'Content-Type': 'application/json'}, // Content-Type 추가
        body: jsonEncode(userInfoBody),
      );

      var userInfoResponseData = jsonDecode(userInfoResponse.body);
      //print('userInfoResponseData: $userInfoResponseData');

      //print(userInfoResponseData);
      user.setNickname(userInfoResponseData["nickname"]);
      user.setTemperature(userInfoResponseData["temperature"]);
      //user.setLocation(userInfoResponseData["location"]);
      user.setBorrowCount(userInfoResponseData["borrow_count"]);
      user.setLendCount(userInfoResponseData["lend_count"]);
      user.setTotalMoney(userInfoResponseData["total_money"]);
      user.setBorrowList(userInfoResponseData["borrow_list"]);
      user.setLendList(userInfoResponseData["lend_list"]);

      var getPostsUri = Uri.parse('$baseUri/get_posts');
      var getPostsResponse = await http.get(
        getPostsUri,
        headers: {'Content-Type': 'application/json'}, // Content-Type 추가
      );

      var getLocationUri = Uri.parse('$baseUri/get_location');
      var getLocationResponse = await http.get(
        getLocationUri,
        headers: {'Content-Type': 'application/json'}, // Content-Type 추가
      );

      var getPostsResponseData = jsonDecode(getPostsResponse.body);
      //print('getPostsResponseData: $getPostsResponseData');
      posts.setOriginPosts(getPostsResponseData);

      for (var post in getPostsResponseData) {
        var locationId = post['location_id'];
        var getLocationUri = Uri.parse('$baseUri/get_location/$locationId');
        var getLocationResponse = await http.get(
          getLocationUri,
          headers: {'Content-Type': 'application/json'},
        );
        print(
            'API response for location $locationId: ${getLocationResponse.body}'); // API 응답 출력

        if (getLocationResponse.statusCode == 200) {
          var locationData = jsonDecode(getLocationResponse.body);
          post['locationData'] = locationData; // 각 post에 위치 정보를 추가
        } else {
          print('Failed to load location for post ${post['post_id']}');
        }
        print('Post ID: ${post['post_id']}');
        print('Location Data: ${post['locationData']}');
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      // 로그인 실패 시 오류 메시지를 출력
      print('로그인 실패: ${loginResponseData['message']}');
    }
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
                  _testLogin(
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
