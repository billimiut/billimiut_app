import 'package:flutter/material.dart';

class SenderChattingBox extends StatelessWidget {
  const SenderChattingBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 8.0,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFB900),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: const Text(
            "안녕하세요! 귤 나눔받고싶어서 연락드렸습니다!",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
