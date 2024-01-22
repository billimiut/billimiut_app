import 'package:billimiut_app/widgets/borrow_lend_toggle.dart';
import 'package:billimiut_app/widgets/image_uploader.dart';
import 'package:flutter/material.dart';
import '../widgets/date_time_picker.dart';
import '../widgets/post_writing_text.dart';

class PostWritingScreen extends StatefulWidget {
  const PostWritingScreen({super.key});

  @override
  State<PostWritingScreen> createState() => _PostWritingScreenState();
}

class _PostWritingScreenState extends State<PostWritingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            // X 버튼이 눌렸을 때 수행할 작업 작성
          },
        ),
        title: const Text(
          '글 작성',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            PostWritingText(text: "제목"),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '제목',
              ),
            ),
            Row(
              children: [
                PostWritingText(text: "빌림 품목"),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '빌림 품목',
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                PostWritingText(text: "빌림 머니"),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '빌림/빌려줌의 대가를 입력해주세요.',
                      prefixText: "₩",
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                PostWritingText(text: "빌림 기간"),
                DateTimePicker(initialText: "시작 날짜"),
                Text('~'),
                DateTimePicker(initialText: "종료 날짜"),
              ],
            ),
            Row(
              children: [
                PostWritingText(text: "위치"),
              ],
            ),
            Row(
              children: [
                PostWritingText(text: "빌림/빌려줌"),
                BorrowLendToggle(),
              ],
            ),
            PostWritingText(text: "사진"),
            ImageUploader(),
            PostWritingText(text: "자세한 설명"),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '빌림/빌려줌에 대한 내용을 자세히 작성해주세요.',
                ),
                maxLines: 5,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // 버튼이 눌렸을 때 수행할 작업을 여기에 작성하세요.
              },
              child: Text('작성 완료'),
            )
          ],
        ),
      ),
    );
  }
}
