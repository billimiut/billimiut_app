import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(
        const Duration(seconds: 5),
        () => Navigator.pushReplacementNamed(
            context, "/login")); // 3초 후에 로그인 페이지로 이동합니다.
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
