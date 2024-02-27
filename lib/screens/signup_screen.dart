import 'dart:convert';
import 'dart:isolate';

import 'package:billimiut_app/screens/login_screen.dart';
import 'package:billimiut_app/widgets/custom_text_field.dart';
import 'package:billimiut_app/widgets/post_writing_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final String apiEndPoint = dotenv.get("API_END_POINT");

  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  bool _isNicknameValid = false;
  bool _isIdValid = false;
  bool _isPasswordValid = false;
  bool _isPasswordConfirmValid = false;

  String _nicknameErrorMessage = "";
  String _idErrorMessage = "";
  String _passwordErrorMessage = "";
  String _passwordConfirmErrorMessage = "";

  bool _isAllSelected = false;
  bool _isUseSelected = false;
  bool _isPrivacySelected = false;
  bool _isLocationSelected = false;

  void pressLogin() async {
    if (!_isUseSelected ||
        !_isPrivacySelected ||
        !_isNicknameValid ||
        !_isIdValid ||
        !_isPasswordValid ||
        !_isPasswordConfirmValid) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // 모달 내용 구성
          return AlertDialog(
            title: const Text(
              '회원가입 실패',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF565656),
              ),
            ),
            content: const Text(
              '올바른 값을 입력하거나 약관에 동의하세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF565656),
              ),
            ),
            actions: <Widget>[
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF565656),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      var request = Uri.parse('$apiEndPoint/signup');
      var body = {
        "id": _idController.text,
        "pw": _passwordController.text,
        "nickname": _nicknameController.text,
      };
      print(body);
      var response = await http
          .post(
        request,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      )
          .then((value) {
        var data = json.decode(utf8.decode(value.bodyBytes));
        print("data: $data");
        var message = data["message"];
        print("message: $message");
        if (message == "User successfully created") {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              // 모달 내용 구성
              return AlertDialog(
                title: const Text(
                  '회원가입 성공',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF565656),
                  ),
                ),
                content: const Text(
                  "로그인 화면으로 이동하시겠습니까?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF565656),
                  ),
                ),
                actions: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        //Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF565656),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        } else {
          var loginFailMessage = message == "0"
              ? "중복된 계정입니다.\n다른 아이디(이메일 주소)를 입력해주세요."
              : "회원가입에 실패하셨습니다.";
          showDialog(
            context: context,
            builder: (BuildContext context) {
              // 모달 내용 구성
              return AlertDialog(
                title: const Text(
                  '회원가입 실패',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF565656),
                  ),
                ),
                content: Text(
                  loginFailMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF565656),
                  ),
                ),
                actions: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF565656),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }
      }).catchError((e) {
        print("/signup error: $e");
      });
    }
  }

  void onChangeNickname() {
    RegExp pattern = RegExp(r'^(?=.*[a-z0-9가-힣])[a-z0-9가-힣]{2,8}$');
    if (pattern.hasMatch(_nicknameController.text)) {
      setState(() {
        _isNicknameValid = true;
        _nicknameErrorMessage = "";
      });
    } else {
      if (_nicknameController.text.isEmpty) {
        setState(() {
          _isNicknameValid = false;
          _nicknameErrorMessage = '';
        });
      } else {
        setState(() {
          _isNicknameValid = false;
          _nicknameErrorMessage = '닉네임은 2~8자로 영어 또는 숫자 또는 한글을 사용할 수 있습니다.';
        });
      }
    }
  }

  void onChangeId() {
    RegExp pattern = RegExp(
        r'^[0-9a-zA-Z]([-_\.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_\.]?[0-9a-zA-Z])*\.[a-zA-Z]{2,3}$',
        caseSensitive: false);
    if (pattern.hasMatch(_idController.text)) {
      setState(() {
        _isIdValid = true;
        _idErrorMessage = '';
      });
    } else {
      if (_idController.text.isEmpty) {
        setState(() {
          _isIdValid = false;
          _idErrorMessage = '';
        });
      } else {
        setState(() {
          _isIdValid = false;
          _idErrorMessage = '올바르지 않은 형식의 이메일 주소입니다.';
        });
      }
    }
  }

  void onChangePassword() {
    RegExp pattern = RegExp(
        r'^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[$`~!@$!%*#^?&\\(\\)\-_=+]).{8,16}$');
    if (pattern.hasMatch(_passwordController.text)) {
      setState(() {
        _isPasswordValid = true;
        _passwordErrorMessage = '';
      });
    } else {
      if (_passwordController.text.isEmpty) {
        setState(() {
          _isPasswordValid = false;
          _passwordErrorMessage = '';
        });
      } else {
        setState(() {
          _isPasswordValid = false;
          _passwordErrorMessage =
              '비밀번호는 8~16자로 영문, 숫자, 특수문자를 최소 한 가지씩 포함해야 합니다.';
        });
      }
    }
  }

  void onChangePasswordConfirm() {
    if (_passwordConfirmController.text.isEmpty) {
      setState(() {
        _isPasswordConfirmValid = false;
        _passwordConfirmErrorMessage = "";
      });
    } else {
      if (_passwordController.text == _passwordConfirmController.text) {
        setState(() {
          _isPasswordConfirmValid = true;
          _passwordConfirmErrorMessage = "";
        });
      } else {
        setState(() {
          _isPasswordConfirmValid = false;
          _passwordConfirmErrorMessage = "비밀번호가 일치하지 않습니다.";
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _nicknameController.addListener(() {
        onChangeNickname();
      });
      _idController.addListener(() {
        onChangeId();
      });
      _passwordController.addListener(() {
        onChangePassword();
        onChangePasswordConfirm();
      });
      _passwordConfirmController.addListener(() {
        onChangePasswordConfirm();
      });
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _idController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //automaticallyImplyLeading: false,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(
                    left: 8.0, top: 25.0), // '로그인' 텍스트 왼쪽에 간격 추가
                child: Text(
                  '회원가입', // '로그인' 텍스트 추가
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF565656)),
                ),
              ),
              CustomTextField(
                obscureText: false,
                text: "닉네임",
                hintText: "닉네임을 입력세요.",
                errorMessage: _nicknameErrorMessage,
                controller: _nicknameController,
              ),
              CustomTextField(
                  obscureText: false,
                  text: '아이디(이메일 주소)',
                  hintText: '이메일 주소를 입력하세요. ex) id@example.com',
                  errorMessage: _idErrorMessage,
                  controller: _idController),
              CustomTextField(
                  obscureText: true,
                  text: "비밀번호",
                  hintText: "비밀번호를 입력하세요.",
                  errorMessage: _passwordErrorMessage,
                  controller: _passwordController),
              CustomTextField(
                  obscureText: true,
                  text: "비밀번호 확인",
                  hintText: "비밀번호를 한 번 더 입력하세요.",
                  errorMessage: _passwordConfirmErrorMessage,
                  controller: _passwordConfirmController),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  "약관 동의",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8C8C8C),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isAllSelected = !_isAllSelected;
                          if (_isAllSelected) {
                            _isUseSelected = true;
                            _isPrivacySelected = true;
                            _isLocationSelected = true;
                          } else {
                            _isUseSelected = false;
                            _isPrivacySelected = false;
                            _isLocationSelected = false;
                          }
                        });
                      },
                      child: Container(
                        width: 20.0,
                        height: 20.0,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFA0A0A0),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Visibility(
                          visible: _isAllSelected,
                          child: const Center(
                            child: Icon(Icons.check,
                                size: 18.0, // 아이콘 크기 조절
                                color: Color(0xff007DFF) // 아이콘 색상 설정
                                ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    const Text(
                      "전체 약관 동의",
                      style: TextStyle(
                        color: Color(0xffa0a0a0),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 36.0,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isUseSelected = !_isUseSelected;
                          if (_isUseSelected &&
                              _isPrivacySelected &&
                              _isLocationSelected) {
                            _isAllSelected = true;
                          } else {
                            _isAllSelected = false;
                          }
                        });
                      },
                      child: Container(
                        width: 20.0,
                        height: 20.0,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFA0A0A0),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Visibility(
                          visible: _isUseSelected,
                          child: const Center(
                            child: Icon(Icons.check,
                                size: 18.0, // 아이콘 크기 조절
                                color: Color(0xff007DFF) // 아이콘 색상 설정
                                ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    const Text(
                      "이용약관 동의 (필수)",
                      style: TextStyle(
                        color: Color(0xffa0a0a0),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 36.0,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isPrivacySelected = !_isPrivacySelected;
                          if (_isUseSelected &&
                              _isPrivacySelected &&
                              _isLocationSelected) {
                            _isAllSelected = true;
                          } else {
                            _isAllSelected = false;
                          }
                        });
                      },
                      child: Container(
                        width: 20.0,
                        height: 20.0,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFA0A0A0),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Visibility(
                          visible: _isPrivacySelected,
                          child: const Center(
                            child: Icon(Icons.check,
                                size: 18.0, // 아이콘 크기 조절
                                color: Color(0xff007DFF) // 아이콘 색상 설정
                                ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    const Text(
                      "개인정보 수집 및 이용 동의 (필수)",
                      style: TextStyle(
                        color: Color(0xffa0a0a0),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 36.0,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isLocationSelected = !_isLocationSelected;
                          if (_isUseSelected &&
                              _isPrivacySelected &&
                              _isLocationSelected) {
                            _isAllSelected = true;
                          } else {
                            _isAllSelected = false;
                          }
                        });
                      },
                      child: Container(
                        width: 20.0,
                        height: 20.0,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFA0A0A0),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Visibility(
                          visible: _isLocationSelected,
                          child: const Center(
                            child: Icon(Icons.check,
                                size: 18.0, // 아이콘 크기 조절
                                color: Color(0xff007DFF) // 아이콘 색상 설정
                                ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    const Text(
                      "위치정보 서비스 이용 동의 (선택)",
                      style: TextStyle(
                        color: Color(0xffa0a0a0),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB900), // 버튼의 글씨 색 변경
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('회원가입',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  onPressed: () {
                    pressLogin();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
