import 'package:billimiut_app/widgets/borrow_lend_toggle.dart';
import 'package:billimiut_app/widgets/image_uploader.dart';
import 'package:billimiut_app/widgets/location_picker.dart';
import 'package:flutter/material.dart';
import '../widgets/date_time_picker.dart';
import '../widgets/post_writing_text.dart';
import '../models/post.dart';

class PostWritingScreen extends StatefulWidget {
  const PostWritingScreen({super.key});

  @override
  State<PostWritingScreen> createState() => _PostWritingScreenState();
}

class _PostWritingScreenState extends State<PostWritingScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _moneyController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  String _location = '';
  bool _borrow = true;
  String _imageUrl = '';

  @override
  void dispose() {
    _titleController.dispose();
    _itemController.dispose();
    _moneyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _savePost() {
    final String title = _titleController.text;
    final String item = _itemController.text;
    final int money = int.tryParse(_moneyController.text) ?? 0;
    final String description = _descriptionController.text;

    final Post newPost = Post(
      title: title,
      item: item,
      money: money,
      startDate: _startDate,
      endDate: _endDate,
      location: _location,
      borrow: _borrow,
      imageUrl: _imageUrl,
      description: description,
    );

    // test, 나중에 삭제할 것
    print('새로운 Post:');
    print("title" + " " + newPost.title);
    print("item" + " " + newPost.item);
    print("money");
    print(newPost.money);
    print("startdate");
    print(newPost.startDate);
    print("enddate");
    print(newPost.endDate);
    print("location" + " " + newPost.location);
    print("borrow");
    print(newPost.borrow);
    print("imageUrl" + " " + newPost.imageUrl);
    print("description" + " " + newPost.description);
  }

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
        child: ListView(
          children: [
            PostWritingText(text: "제목"),
            TextField(
              controller: _titleController,
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
                    controller: _itemController,
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
                    controller: _moneyController,
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
                DateTimePicker(
                  initialText: "시작 날짜",
                  onDateSelected: (DateTime selectedDate) {
                    _startDate = selectedDate;
                  },
                ),
                Text('~'),
                DateTimePicker(
                  initialText: "종료 날짜",
                  onDateSelected: (DateTime selectedDate) {
                    _endDate = selectedDate;
                  },
                ),
              ],
            ),
            Row(
              children: [
                PostWritingText(text: "위치"),
                LocationPicker(),
              ],
            ),
            Row(
              children: [
                PostWritingText(text: "빌림/빌려줌"),
                BorrowLendToggle(
                  onBorrowPressed: () {
                    _borrow = true;
                  },
                  onLendPressed: () {
                    _borrow = false;
                  },
                ),
              ],
            ),
            PostWritingText(text: "사진"),
            ImageUploader(),
            PostWritingText(text: "자세한 설명"),
            Expanded(
              child: TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '빌림/빌려줌에 대한 내용을 자세히 작성해주세요.',
                ),
                //maxLines: 5,
              ),
            ),
            ElevatedButton(
              onPressed: _savePost,
              child: Text('작성 완료'),
            )
          ],
        ),
      ),
    );
  }
}
