import 'package:flutter/material.dart';

class PostWritingText extends StatelessWidget {
  final String text;
  const PostWritingText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF8C8C8C),
      ),
    );
  }
}
