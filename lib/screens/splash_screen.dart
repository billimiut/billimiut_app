import 'dart:convert';

import 'package:billimiut_app/providers/posts.dart';
import 'package:billimiut_app/providers/user.dart';
import 'package:billimiut_app/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var apiEndPoint = dotenv.get("API_END_POINT");
  @override
  void initState() {
    super.initState();

    readLoginToken();
    // Timer(const Duration(seconds: 3),
    //     () => Navigator.pushReplacementNamed(context, "/login")); // 3초
  }

  Future<void> readLoginToken() async {
    User user = Provider.of<User>(context, listen: false);
    Posts posts = Provider.of<Posts>(context, listen: false);

    FlutterSecureStorage storage = const FlutterSecureStorage();
    var loginToken = await storage.read(
      key: 'login_token',
    );
    if (loginToken != null) {
      // 자동 로그인일 경우
      var loginRequest = Uri.parse('$apiEndPoint/my_info');
      var loginBody = {
        'login_token': loginToken,
      };
      var loginResponse = await http
          .post(
        loginRequest,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(loginBody),
      )
          .then((value) async {
        var loginData = json.decode(utf8.decode(value.bodyBytes));
        print("${loginData["borrow_list"]}");
        user.setUserId(loginData["user_id"]);
        user.setNickname(loginData["nickname"]);
        user.setTemperature(loginData["temperature"]);
        user.setLocation(loginData["locations"]);
        user.setImageUrl(loginData["image_url"]);
        user.setDong(loginData["dong"]);
        user.setBorrowCount(loginData["borrow_count"]);
        user.setLendCount(loginData["lend_count"]);
        user.setLendMoney(loginData["lend_money"]);
        user.setBorrowList(loginData["borrow_list"]);
        user.setLendList(loginData["lend_list"]);
        user.setChatList(loginData["chat_list"]);
        user.setPostsList(loginData["posts"]);

        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        user.setLatitude(position.latitude);
        user.setLongitude(position.longitude);
        var setLocationRequest = Uri.parse('$apiEndPoint/set_location');
        var setLocationBody = {
          "user_id": loginData["user_id"],
          "latitude": user.latitude,
          "longitude": user.longitude,
        };
        var setLocationResponse = await http
            .post(
          setLocationRequest,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(setLocationBody),
        )
            .then((value) async {
          var setLocationData = json.decode(utf8.decode(value.bodyBytes));
          //print(setLocationData["message"]);
          //1.메인페이지에서 getpost
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
          //2.로그인페이지에서 getpost
          /*
          var getPostsRequest = Uri.parse('$apiEndPoint/get_posts');
          var getPostsResponse = await http.get(
            getPostsRequest,
            headers: {'Content-Type': 'application/json'}, // Content-Type 추가
          ).then((value) {
            var getPostsData = jsonDecode(value.body);
            getPostsData = json.decode(utf8.decode(value.bodyBytes));
            posts.setOriginPosts(getPostsData);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          }).catchError((e) {
            print("/get_posts error: $e");
          });*/
        }).catchError((e) {
          print("/set_location error: $e");
        });
      }).catchError((e) {
        print("/my_info error: $e");
      });
    } else {
      // 자동 로그인이 아닐 경우
      Timer(const Duration(seconds: 3),
          () => Navigator.pushReplacementNamed(context, "/login")); // 3초
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFFFFEBB6), Colors.white], // 원하는 그라데이션 색상을 지정하세요.
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '이웃 사회의 정으로\n    언제, 어디서든',
                style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 16.0,
                    color: Color(0xFF8C8C8C)),
              ),
              const SizedBox(height: 10.0),
              SvgPicture.asset('assets/logo.svg'),
              const SizedBox(height: 15.0),
              const Text(
                '"빌리다"',
                style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 16.0,
                    color: Color(0xFF8C8C8C)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
