import 'package:billimiut_app/widgets/borrow_lend_toggle.dart';
import 'package:billimiut_app/widgets/image_uploader.dart';
import 'package:billimiut_app/widgets/location_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final String _location = '';
  bool _borrow = true;
  final String _imageUrl = '';

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
    print("title ${newPost.title}");
    print("item ${newPost.item}");
    print("money");
    print(newPost.money);
    print("startdate");
    print(newPost.startDate);
    print("enddate");
    print(newPost.endDate);
    print("location ${newPost.location}");
    print("borrow");
    print(newPost.borrow);
    print("imageUrl ${newPost.imageUrl}");
    print("description ${newPost.description}");

    uploadPostToFirebase(newPost);
  }

  //database에 저장
  void uploadPostToFirebase(Post newPost) async {
    CollectionReference posts = FirebaseFirestore.instance.collection('posts');

    posts
        .add({
          'title': newPost.title,
          'item': newPost.item,
          'money': newPost.money,
          'startDate': newPost.startDate,
          'endDate': newPost.endDate,
          'location': newPost.location,
          'borrow': newPost.borrow,
          'imageUrl': newPost.imageUrl,
          'description': newPost.description
        })
        .then((value) => print("Post Added"))
        .catchError((error) => print("Failed to add post: $error"));
  }

  @override
  void initState() {
    super.initState();
  }

/*
  void testDB() {
    DatabaseSvc().writeDB();
  }
*/
  @override
  Widget build(BuildContext context) {
    //print('Building PostWritingScreen');
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const SizedBox(
              height: 10,
            ),
            TextField(
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '제목',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: '제목을 입력하세요.',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              controller: _itemController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '품목',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: '품목을 입펵하세요.',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              controller: _moneyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: '빌림 머니',
                labelStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: '가격을 입력해주세요.',
                prefix: Container(
                  margin: const EdgeInsets.only(right: 4.0),
                  child: const Text(
                    "₩",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                const PostWritingText(text: "빌림 기간"),
                const SizedBox(
                  width: 12,
                ),
                DateTimePicker(
                  initialText: "시작 날짜",
                  onDateSelected: (DateTime selectedDate) {
                    _startDate = selectedDate;
                  },
                ),
                const Text(
                  '~',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                DateTimePicker(
                  initialText: "종료 날짜",
                  onDateSelected: (DateTime selectedDate) {
                    _endDate = selectedDate;
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                PostWritingText(text: "위치"),
                SizedBox(
                  width: 12,
                ),
                LocationPicker(),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                const PostWritingText(text: "빌림/빌려줌"),
                const SizedBox(
                  width: 12,
                ),
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
            const PostWritingText(text: "사진 등록"),
            const ImageUploader(),
            const SizedBox(
              height: 10,
            ),
            TextField(
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              controller: _descriptionController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '자세한 설명',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: '빌림/빌려줌에 대한 내용을 자세히 작성해주세요.',
              ),
              //maxLines: 5,
            ),
            const SizedBox(
              height: 5,
            ),
            ElevatedButton(
              onPressed: _savePost,
              child: const Text(
                '작성 완료',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
