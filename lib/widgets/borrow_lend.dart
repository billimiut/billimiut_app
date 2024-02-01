import 'package:flutter/material.dart';

class BorrowLendTab extends StatelessWidget {
  final bool selected;
  final String text;

  const BorrowLendTab({
    super.key,
    required this.selected,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: selected ? const Color(0xff007DFF) : const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: selected ? const Color(0xFFF4F4F4) : const Color(0xff007DFF),
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}
