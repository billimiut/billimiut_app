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

    readAccessToken();
    // Timer(const Duration(seconds: 3),
    //     () => Navigator.pushReplacementNamed(context, "/login")); // 3초
  }

  Future<void> readAccessToken() async {
    User user = Provider.of<User>(context, listen: false);
    Posts posts = Provider.of<Posts>(context, listen: false);

    FlutterSecureStorage storage = const FlutterSecureStorage();
    var token = await storage.read(
      key: 'access_token',
    );
    if (token != null) {
      // 자동 로그인일 경우

      var myInfoRequest = Uri.parse('$apiEndPoint/users/my_info');

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      var myInfoResponse =
          await http.get(myInfoRequest, headers: headers).then((value) async {
        var myInfoData = json.decode(utf8.decode(value.bodyBytes));
        print("myInfoData: ${myInfoData["female"].runtimeType}");
        user.setId(myInfoData["id"]);
        user.setNickname(myInfoData["nickname"]);
        user.setFemale(myInfoData["female"]);
        user.setKeywords(myInfoData["keywords"]);
        //user.setTemperature(myInfoData["temperature"]);
        //user.setLocation(myInfoData["locations"]);
        user.setProfileImage(myInfoData["profile_image"]);
        //user.setDong(myInfoData["dong"]);
        user.setBorrowCount(myInfoData["borrow_count"]);
        user.setLendCount(myInfoData["lend_count"]);
        user.setBorrowMoney(myInfoData["borrow_money"]);
        user.setLendMoney(myInfoData["lend_money"]);
        user.setBorrowList(myInfoData["borrow_list"]);
        user.setLendList(myInfoData["lend_list"]);
        user.setChatList(myInfoData["chat_list"]);
        //user.setPostsList(myInfoData["posts"]);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );

        // Position position = await Geolocator.getCurrentPosition(
        //   desiredAccuracy: LocationAccuracy.high,
        // );
        // user.setLatitude(position.latitude);
        // user.setLongitude(position.longitude);
        // // var setLocationRequest = Uri.parse('$apiEndPoint/set_location');
        // // var setLocationBody = {
        // //   "user_id": loginData["user_id"],
        // //   "latitude": user.latitude,
        // //   "longitude": user.longitude,
        // // };
        // // var setLocationResponse = await http
        // //     .post(
        // //   setLocationRequest,
        // //   headers: {'Content-Type': 'application/json'},
        // //   body: jsonEncode(setLocationBody),
        // // )
        // //     .then((value) async {
        // //   var setLocationData = json.decode(utf8.decode(value.bodyBytes));
        // //   //print(setLocationData["message"]);
        // //   //1.메인페이지에서 getpost
        // //   Navigator.push(
        // //     context,
        // //     MaterialPageRoute(builder: (context) => const MainScreen()),
        // //   );
        // //   //2.로그인페이지에서 getpost
        // //   /*
        // //   var getPostsRequest = Uri.parse('$apiEndPoint/get_posts');
        // //   var getPostsResponse = await http.get(
        // //     getPostsRequest,
        // //     headers: {'Content-Type': 'application/json'}, // Content-Type 추가
        // //   ).then((value) {
        // //     var getPostsData = jsonDecode(value.body);
        // //     getPostsData = json.decode(utf8.decode(value.bodyBytes));
        // //     posts.setOriginPosts(getPostsData);
        // //     Navigator.push(
        // //       context,
        // //       MaterialPageRoute(builder: (context) => const MainScreen()),
        // //     );
        // //   }).catchError((e) {
        // //     print("/get_posts error: $e");
        // //   });*/
        // // }).catchError((e) {
        // //   print("/set_location error: $e");
        // // });
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
