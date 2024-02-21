import 'dart:isolate';

import 'package:billimiut_app/widgets/custom_text_field.dart';
import 'package:billimiut_app/widgets/post_writing_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var apiEndPoint = dotenv.get("API_END_POINT");

  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  final bool _isNicknameValid = false;
  final bool _isIdValid = false;
  final bool _isPasswordValid = false;
  bool _isPasswordConfirmValid = false;

  bool _isAllSelected = false;
  bool _isUseSelected = false;
  bool _isPrivacySelected = false;
  bool _isLocationSelected = false;

  void pressLogin() {
    if (_passwordController.text == _passwordConfirmController.text) {
      setState(() {
        _isPasswordConfirmValid = true;
        print(_isPasswordConfirmValid);
      });
    }
    if (!_isUseSelected ||
        !_isPrivacySelected ||
        !_isNicknameValid ||
        !_isIdValid ||
        !_isPasswordValid ||
        !_isPasswordConfirmValid) {
      return;
    }
  }

  @override
  void initState() {
    super.initState();
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
        automaticallyImplyLeading: false,
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
                text: "닉네임",
                hintText: "닉네임을 입력세요.",
                controller: _nicknameController,
              ),
              CustomTextField(
                  text: '아이디(이메일주소)',
                  hintText: '이메일 주소를 입력하세요. ex) id@example.com',
                  controller: _idController),
              CustomTextField(
                  text: "비밀번호",
                  hintText: "비밀번호를 입력하세요.",
                  controller: _passwordController),
              CustomTextField(
                  text: "비밀번호 확인",
                  hintText: "비밀번호를 한 번 더 입력하세요.",
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
                height: 20,
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
