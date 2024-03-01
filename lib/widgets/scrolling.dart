import 'dart:async';

import 'package:flutter/material.dart';
import 'package:billimiut_app/providers/posts.dart';

class ScrollingText extends StatefulWidget {
  final List<dynamic> emergencyPosts;

  const ScrollingText({super.key, required this.emergencyPosts});

  @override
  _ScrollingTextState createState() => _ScrollingTextState();
}

class _ScrollingTextState extends State<ScrollingText> {
  int _currentIndex = 0;
  Timer? _timer; // Timer 변수를 nullable로 선언합니다.

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.emergencyPosts.length;
      });
    });
  }

  @override
  void dispose() {
    // _timer가 null이 아닐 때 dispose() 메서드를 실행합니다.
    _timer?.cancel(); // ?. 연산자를 사용하여 null 체크 후 cancel() 메서드 호출
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(seconds: 1),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0), // 상단에 여백 추가
        child: Text(
          "'${widget.emergencyPosts[_currentIndex]['nickname']}'님이 '${widget.emergencyPosts[_currentIndex]['detail_address']}'에서 '${widget.emergencyPosts[_currentIndex]['item']}'(이)가 필요합니다.",
          key: ValueKey<String?>(
              widget.emergencyPosts[_currentIndex]['nickname']),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.start, // 텍스트를 왼쪽에서 시작
        ),
      ),
    );
  }
}
