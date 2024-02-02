import 'package:flutter/material.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // < 버튼이 눌렸을 때 수행할 작업 작성
          },
        ),
        title: const Text(
          "설정",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF565656),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: const Center(
          child: Text("마이페이지"),
        ),
      ),
    );
  }
}
