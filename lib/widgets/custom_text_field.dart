import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final bool obscureText;
  final String text;
  final String hintText;
  final String errorMessage;
  final TextEditingController controller;

  const CustomTextField({
    super.key,
    required this.obscureText,
    required this.text,
    required this.hintText,
    required this.errorMessage,
    required this.controller,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.text,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8C8C8C),
                  ),
                ),
                const SizedBox(
                  width: 4.0,
                ),
                const Text(
                  "*",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ],
            )),
        const SizedBox(
          height: 4.0,
        ),
        SizedBox(
          height: 40,
          child: TextField(
            controller: widget.controller,
            obscureText: widget.obscureText,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ), // TextField의 글자색 변경
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0, horizontal: 16.0), // 텍스트 필드 세로 패딩 조정
              hintText: widget.hintText,
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 2.0,
        ),
        Visibility(
          visible: widget.errorMessage != "",
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              widget.errorMessage,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
