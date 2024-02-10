import 'package:flutter/material.dart';

class RecieverChattingBox extends StatelessWidget {
  const RecieverChattingBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text("12:03"),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 8.0,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: const Text(
            "네!\n아직 많이 남아있습니다~!\n신관 A동으로 오시면 챗 주세요!",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFFA0A0A0),
            ),
          ),
        ),
      ],
    );
  }
}
