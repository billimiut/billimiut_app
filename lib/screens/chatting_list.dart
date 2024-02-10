import 'package:flutter/material.dart';

class ChattingList extends StatefulWidget {
  const ChattingList({super.key});

  @override
  State<ChattingList> createState() => _ChattingListState();
}

class _ChattingListState extends State<ChattingList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(
        child: Text(
          "채팅 페이지",
        ),
      ),
    );
  }
}
