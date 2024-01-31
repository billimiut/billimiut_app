import 'package:flutter/material.dart';

class PostWritingText extends StatelessWidget {
  final String text;
  const PostWritingText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
