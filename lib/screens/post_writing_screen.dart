import 'package:billimiut_app/widgets/borrow_lend_share.dart';
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
  final TextEditingController _locationController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  final String _location = '';
  final bool _borrow = true;
  final String _imageUrl = '';

  @override
  void dispose() {
    _titleController.dispose();
    _itemController.dispose();
    _moneyController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 5,
        ),
        child: ListView(
          children: [
            const Text(
              '글 작성',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF565656),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const PostWritingText(text: "제목"),
            const SizedBox(
              height: 8,
            ),
            TextField(
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              controller: _titleController,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFFF4F4F4),
                border: InputBorder.none,
                hintText: '제목을 입력하세요.',
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const PostWritingText(text: "빌림 품목"),
            const SizedBox(
              height: 8,
            ),
            TextField(
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              controller: _itemController,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFFF4F4F4),
                border: InputBorder.none,
                hintText: '품목을 입펵하세요.',
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const PostWritingText(text: "금액"),
            const SizedBox(
              height: 8,
            ),
            const Row(
              children: [
                BorrowLendShareTab(
                  selected: true,
                  text: "빌림",
                ),
                SizedBox(
                  width: 8,
                ),
                BorrowLendShareTab(
                  selected: false,
                  text: "빌려줌",
                ),
                SizedBox(
                  width: 8,
                ),
                BorrowLendShareTab(
                  selected: false,
                  text: "나눔",
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            TextField(
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              controller: _moneyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFFF4F4F4),
                border: InputBorder.none,
                hintText: '가격을 입력해주세요.',
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const PostWritingText(text: "빌림 기간 및 시간"),
            Row(
              children: [
                const SizedBox(
                  height: 16,
                ),
                DateTimePicker(
                  initialText: "시작 날짜 및 시간",
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
                  initialText: "종료 날짜 및 시간",
                  onDateSelected: (DateTime selectedDate) {
                    _endDate = selectedDate;
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            const PostWritingText(text: "사진 등록"),
            const ImageUploader(),
            const SizedBox(
              height: 15,
            ),
            const PostWritingText(text: "내용 입력"),
            const SizedBox(
              height: 8,
            ),
            TextFormField(
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFFA0A0A0),
              ),
              controller: _descriptionController,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFFF4F4F4),
                border: InputBorder.none,
                hintText: '내용을 입력하세요.',
              ),
              maxLines: 10,
            ),
            const SizedBox(
              height: 15,
            ),
            const PostWritingText(text: "위치"),
            const SizedBox(
              height: 8,
            ),
            TextField(
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              controller: _locationController,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFFF4F4F4),
                border: InputBorder.none,
                hintText: '나의 위치를 검색하세요',
                prefixIcon: Icon(
                  Icons.search,
                  color: Color(0xFF8C8C8C),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const LocationPicker(),
            const SizedBox(
              height: 15,
            ),
            const SizedBox(
              height: 40,
            ),
            ElevatedButton(
              onPressed: _savePost,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  const Color(0xFFFFB900),
                ),
              ),
              child: const Text(
                '저장',
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
