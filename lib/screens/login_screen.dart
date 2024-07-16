import 'dart:convert';
import 'dart:io';
import 'package:billimiut_app/providers/posts.dart';
import 'package:billimiut_app/providers/user.dart';
import 'package:billimiut_app/screens/kakao_login_screen.dart';
import 'package:billimiut_app/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:billimiut_app/screens/main_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  bool _autoLogin = false;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<void> saveToken(String key, String value) async {
    await secureStorage.write(
      key: key,
      value: value,
    );
  }

  Future<void> _pressLogin(String id, String pw, User user, Posts posts) async {
    var apiEndPoint = dotenv.get("API_END_POINT");
    var loginRequest = Uri.parse('$apiEndPoint/users/login');
    var loginBody = {
      "id": id,
      "pw": pw,
    };
    var loginReponse = await http
        .post(
      loginRequest,
      headers: {'Content-Type': 'application/json'}, // Content-Type 추가
      body: jsonEncode(loginBody),
    )
        .then((value) async {
      var loginData = json.decode(utf8.decode(value.bodyBytes));

      var myInfoData = loginData["my_info"];

      if (myInfoData["_id"] != null) {
        user.setUuid(myInfoData["_id"]);
      }

      if (myInfoData["id"] != null) {
        user.setId(myInfoData["id"]);
      }
      if (myInfoData["nickname"] != null) {
        user.setNickname(myInfoData["nickname"]);
      }
      if (myInfoData["female"] != null) {
        user.setFemale(myInfoData["female"]);
      }
      if (myInfoData["keywords"] != null) {
        user.setKeywords(myInfoData["keywords"]);
      }
      if (myInfoData["temperature"] != null) {
        user.setTemperature(myInfoData["temperature"]);
      }

      //user.setLocation(myInfoData["locations"]);
      if (myInfoData["profile_image"] != null) {
        user.setProfileImage(myInfoData["profile_image"]);
      }
      //user.setDong(myInfoData["dong"]);
      if (myInfoData["borrow_count"] != null) {
        user.setBorrowCount(myInfoData["borrow_count"]);
      }
      if (myInfoData["lend_count"] != null) {
        user.setLendCount(myInfoData["lend_count"]);
      }
      if (myInfoData["borrow_money"] != null) {
        user.setBorrowMoney(myInfoData["borrow_money"]);
      }
      if (myInfoData["lend_money"] != null) {
        user.setLendMoney(myInfoData["lend_money"]);
      }
      if (myInfoData["borrow_list"] != null) {
        user.setBorrowList(myInfoData["borrow_list"]);
      }
      if (myInfoData["lend_list"] != null) {
        user.setLendList(myInfoData["lend_list"]);
      }
      if (myInfoData["chat_list"] != null) {
        user.setChatList(myInfoData["chat_list"]);
      }
      if (myInfoData["posts"] != null) {
        user.setPostsList(myInfoData["posts"]);
      }

      _autoLogin ? saveToken("access_token", loginData["access_token"]) : null;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );

      // user.setUserId(loginData["user_id"]);
      // user.setNickname(loginData["nickname"]);
      // user.setTemperature(loginData["temperature"]);
      // user.setLocation(loginData["locations"]);
      // user.setProfileImage(loginData["profile_image"]);
      // user.setDong(loginData["dong"]);
      // user.setBorrowCount(loginData["borrow_count"]);
      // user.setLendCount(loginData["lend_count"]);
      // user.setBorrowMoney(loginData["borrow_money"]);
      // user.setLendMoney(loginData["lend_mondh"]);
      // user.setBorrowList(loginData["borrow_list"]);
      // user.setLendList(loginData["lend_list"]);
      // user.setChatList(loginData["chat_list"]);
      // user.setPostsList(loginData["posts"]);

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      user.setLatitude(position.latitude);
      user.setLongitude(position.longitude);
      // var setLocationRequest = Uri.parse('$apiEndPoint/set_location');
      // var setLocationBody = {
      //   "user_id": loginData["user_id"],
      //   "latitude": user.latitude,
      //   "longitude": user.longitude,
      // };
      // var setLocationResponse = await http
      //     .post(
      //   setLocationRequest,
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode(setLocationBody),
      // )
      //     .then((value) async {
      //   var setLocationData = json.decode(utf8.decode(value.bodyBytes));
      //   //print(setLocationData["message"]);
      //   //1.main페이지에서 getpost
      //   _autoLogin ? saveToken("login_token", loginData["user_id"]) : null;
      //   print(_autoLogin);
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => const MainScreen()),
      //   );
      //   //2.login페이지에서 getpost
      //   /*
      //   var getPostsRequest = Uri.parse('$apiEndPoint/get_posts');
      //   var getPostsResponse = await http.get(
      //     getPostsRequest,
      //     headers: {'Content-Type': 'application/json'}, // Content-Type 추가

      //   ).then((value) {
      //     var getPostsData = jsonDecode(value.body);
      //     getPostsData = json.decode(utf8.decode(value.bodyBytes));
      //     posts.setOriginPosts(getPostsData);
      //     _autoLogin ? saveToken("login_token", loginData["user_id"]) : null;
      //     print(_autoLogin);
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => const MainScreen()),
      //     );
      //   }).catchError((e) {
      //     print("/get_posts error: $e");
      //   });*/
      // }).catchError((e) {
      //   print("/set_location error: $e");
      // });
    }).catchError((e) {
      print("/login error: $e");
    });
  }

  Future<void> _pressKakaoLogin() async {
    var apiEndPoint = dotenv.get("API_END_POINT");
    var kakaoLoginRequest = Uri.parse('$apiEndPoint/users/login/kakao');
    if (await canLaunchUrl(kakaoLoginRequest)) {
      await launchUrl(kakaoLoginRequest);
    } else {
      throw 'Could not launch $kakaoLoginRequest';
    }
  }

  Future<void> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    // Handle permission result
    if (permission == LocationPermission.denied) {
      // 권한이 거부되었을 때의 처리
    } else if (permission == LocationPermission.deniedForever) {
      // 사용자가 "영원히 허용하지 않음"을 선택한 경우의 처리
    } else {
      // 권한이 허용되었을 때의 처리
      // 여기서 위치 서비스를 사용할 수 있습니다.
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestLocationPermission();
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
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 5,
        ),
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
                obscureText: true, // 이 부분을 추가합니다
              ),
            ),
            const SizedBox(height: 10),
            Row(children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _autoLogin = !_autoLogin;
                  });
                },
                child: Container(
                  width: 26.0,
                  height: 26.0,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFA0A0A0),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Visibility(
                    visible: _autoLogin,
                    child: const Center(
                      child: Icon(Icons.check,
                          size: 24.0, // 아이콘 크기 조절
                          color: Color(0xff007DFF) // 아이콘 색상 설정
                          ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              const Text(
                "자동 로그인",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8C8C8C),
                ),
              ),
            ]),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpScreen()),
                );
              },
            ),
            InkWell(
              onTap: () async {
                print("카카오 로그인 눌림");
                // var response = await Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) => const KakaoLoginScreen()),
                // );
                // if (response != null) {
                //   // response를 이용한 후속 처리
                //   print('로그인 성공: $response');
                // }
                _pressKakaoLogin();
                /*
                // 카카오 로그인 구현 예제

                // 카카오톡 실행 가능 여부 확인
                // 카카오톡 실행이 가능하면 카카오톡으로 로그인, 아니면 카카오계정으로 로그인
                if(await isKakaoTalkInstalled()){
                  try{
                    await UserApi.instance.loginWithKakaoTalk();
                    print('카카오톡으로 로그인 성공');
                  }catch(error){
                    print('카카오톡으로 로그인 실패 $error');

                    // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
                    // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
                    if(error is PlatformException && error.code == 'CANCELED'){
                      return;
                    }
                    // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
                    try{
                      await UserApi.instance.loginWithKakaoAccount();
                      print('카카오계정으로 로그인 성공');
                    }catch(error){
                      print('카카오계정으로 로그인 실패 $error');
                    }
                  }
                }else{
                  try{
                    await UserApi.instance.loginWithKakaoAccount();
                    print('카카오계정으로 로그인 성공');
                  }catch(error){
                    print('카카오계정으로 로그인 실패 $error');
                  }
                }

                if(await AuthApi.instance.hasToken()){
                  try{
                    AccessTokenInfo tokenInfo =
                        await UserApi.instance.accessTokenInfo();
                    print('토큰 유효성 체크 성공 ${tokenInfo.id} ${tokenInfo.expiresIn}');
                  }catch(error){
                    if(error is KakaoException && error.isInvalidTokenError()){
                      print('토큰 만료 $error');
                    }else{
                      print('토큰 정보 조회 실패 $error');
                    }

                    try{
                      // 카카오계정으로 로그인
                      OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
                      print('로그인 성공 ${token.accessToken}');
                    }catch (error){
                      print('로그인 실패 $error');
                    }
                  }
                }else{
                  print('발급된 토큰 없음');
                  try{
                    OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
                    print('로그인 성공 ${token.accessToken}');
                  }catch(error){
                    print('로그인 실패 $error');
                  }
                }

                try{
                  AccessTokenInfo tokenInfo = await UserApi.instance.accessTokenInfo();
                  print('토큰 정보 보기 성공'
                        '\n회원정보: ${tokenInfo.id}'
                        '\n만료시간: ${tokenInfo.expiresIn} 초');
                }catch (error){
                  print('토큰 정보 보기 실패 $error');
                }
                */
              },
              child: Image.asset('assets/kakao_login_medium_narrow.png'),
            ),
          ],
        ),
      ),
    );
  }
}
