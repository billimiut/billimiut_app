import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:billimiut_app/screens/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /*
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  Future<void> _testLogin(String id, String pw) async {
    var uri = Uri.parse('http://43.200.243.222:5000/login');
    var body = {
      "id": id,
      "pw": pw,
    };
    var response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'}, // Content-Type 추가
      body: jsonEncode(body),
    );

    // 응답을 json 형식으로 변환
    var responseData = jsonDecode(response.body);

    // 응답으로부터 로그인 성공 여부를 판단. 여기서는 'success' 필드를 확인한다고 가정
    if (responseData['success']) {
      // 로그인 성공 시 메인 페이지로 이동
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      // 로그인 실패 시 오류 메시지를 출력
      print('로그인 실패: ' + responseData['message']);
    }
  }
*/
  @override
  Widget build(BuildContext context) {
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
                //controller: _idController,
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
                //controller: _pwController,
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
                  // _testLogin(_idController.text, _pwController.text);
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
