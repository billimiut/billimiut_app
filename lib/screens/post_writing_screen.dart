import 'dart:convert';

import 'package:billimiut_app/providers/user.dart';
import 'package:billimiut_app/screens/main_screen.dart';
import 'package:billimiut_app/widgets/borrow_lend_tab.dart';
import 'package:billimiut_app/widgets/image_uploader.dart';
import 'package:billimiut_app/widgets/location_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../widgets/date_time_picker.dart';
import '../widgets/post_writing_text.dart';
import '../models/post.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import '../widgets/change_notifier.dart';

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
  final TextEditingController _placeController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  final String _location = '';
  var _borrow = true;
  final String _imageUrl = '';
  bool _female = false;
  bool _emergency = false;
  bool _isClicked = false;
  final List<String> categories = [
    '디지털기기',
    '생활가전',
    '가구/인테리어',
    '여성용품',
    '일회용품',
    '생활용품',
    '주방용품',
    '캠핑용품',
    '애완용품',
    '스포츠용품',
    '놀이용품',
    '무료나눔',
    '의류',
    '공구',
    '식물',
  ];
  int selectedIndex = -1;
  var selectedCategory = "카테고리 선택";

  @override
  void dispose() {
    _titleController.dispose();
    _itemController.dispose();
    _moneyController.dispose();
    _descriptionController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  void _testLogin() async {
    var baseUri = dotenv.get("API_END_POINT");
    var uri = Uri.parse('$baseUri/login');
    var body = {
      "id": "test1@gmail.com",
      "pw": "111111",
    };
    var response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'}, // Content-Type 추가
      body: jsonEncode(body),
    );
    print(response.body);
  }

  void _savePost(User user) async {
    // final String title = _titleController.text;
    // final String item = _itemController.text;
    // final int money = int.tryParse(_moneyController.text) ?? 0;
    // final String description = _descriptionController.text;

    // final Post newPost = Post(
    //   title: title,
    //   item: item,
    //   money: money,
    //   startDate: _startDate,
    //   endDate: _endDate,
    //   location: _location,
    //   borrow: _borrow,
    //   imageUrl: _imageUrl,
    //   description: description,
    //   female: false,
    // );

    // uploadPostToFirebase(newPost);

    if (selectedIndex == -1 || selectedCategory == "카테고리 선택") {
      // 카테고리 선택 모달창 띄우기
      return;
    }
    DateTime currentDate = DateTime.now();
    Duration difference = _startDate.difference(currentDate);
    if (difference.inMinutes <= 30) {
      setState(() {
        _emergency = true;
      });
    } else {
      setState(() {
        _emergency = false;
      });
    }
    var baseUri = dotenv.get("API_END_POINT");
    var uri = Uri.parse('$baseUri/add_post');
    var body = {
      "user_id": user.userId,
      "post": {
        "post_id": "",
        "nickname": user.nickname,
        "title": _titleController.text,
        "item": _itemController.text,
        "category": selectedCategory,
        "image_url": [],
        "money": int.parse(_moneyController.text),
        "borrow": _borrow,
        "description": _descriptionController.text,
        "emergency": _emergency,
        "start_date": _startDate,
        "end_date": _endDate,
        "location_id": "",
        "female": _female,
        "status": "",
        "borrower_user_id": "",
        "lender_user_id": "",
      },
      "location": {
        "location_id": "",
        "map": {
          "latitiude": 37.29378,
          "longitude": 126.9764,
        },
        "address": "",
        "detail_address": "",
        "dong": "",
      }
    };

    // var response = await http.post(
    //   uri,
    //   headers: {'Content-Type': 'application/json'}, // Content-Type 추가
    //   body: jsonEncode(body),
    // ).then((value) => {
    //   print(value.body);
    // });
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
          'description': newPost.description,
          'female': newPost.female
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

  void _uploadImages() async {
    final imageList = Provider.of<ImageList>(context, listen: false);
    for (var image in imageList.selectedImages) {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      try {
        TaskSnapshot snapshot = await FirebaseStorage.instance
            .ref('post_images/$fileName')
            .putFile(image);

        String downloadUrl = await snapshot.ref.getDownloadURL();

        print('Image $fileName uploaded successfully. URL: $downloadUrl');
        // downloadUrl을 데이터베이스에 저장해야 함
      } on FirebaseException catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageList = Provider.of<ImageList>(context, listen: false);
    User user = Provider.of<User>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            // X 버튼이 눌렸을 때 수행할 작업 작성
            Navigator.pop(context);
          },
        ),
        title: const Text(""),
        actions: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB900),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "임시 저장",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(
            width: 16,
          ),
        ],
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
            const PostWritingText(text: "카테고리"),
            Container(
              padding: const EdgeInsets.all(10.0),
              color: const Color(0xFFF4F4F4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedCategory,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isClicked = !_isClicked;
                      });
                    },
                    child: const Icon(
                      Icons.arrow_drop_down,
                      size: 32,
                      color: Color(0xFFFFB900),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: categories.asMap().entries.map((entry) {
                int index = entry.key;
                String category = entry.value;
                return Visibility(
                  visible: _isClicked,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                        selectedIndex = index;
                        _isClicked = !_isClicked;
                        print("$selectedIndex : $selectedCategory");
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: selectedIndex == index
                            ? const Color(0xFFFFB900)
                            : const Color(0xFFF4F4F4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            category,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 32,
                            color: selectedIndex == index
                                ? const Color(0xFFFFB900)
                                : const Color(0xFFF4F4F4),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(
              height: 15,
            ),
            const PostWritingText(text: "기타"),
            const SizedBox(
              height: 8,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _female = !_female;
                });
                //print(_female);
              },
              child: Row(children: [
                Container(
                  width: 26.0,
                  height: 26.0,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFA0A0A0),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Visibility(
                    visible: _female,
                    child: const Center(
                      child: Icon(Icons.check,
                          size: 24.0, // 아이콘 크기 조절
                          color: Color(0xff007DFF) // 아이콘 색상 설정
                          ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                const Text(
                  "여성만 확인 가능",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8C8C8C),
                  ),
                ),
              ]),
            ),
            const SizedBox(
              height: 15,
            ),
            const PostWritingText(text: "거래 방식"),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _borrow = true;
                    });
                  },
                  child: BorrowLendTab(
                    selected: _borrow ? true : false,
                    text: "빌림",
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _borrow = false;
                    });
                  },
                  child: BorrowLendTab(
                    selected: _borrow ? false : true,
                    text: "빌려줌",
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            const PostWritingText(text: "금액"),
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
            const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PostWritingText(text: "사진 등록"),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  "사진은 최대 3장까지 등록할 수 있습니다.",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
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
                color: Colors.black,
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
              controller: _placeController,
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
              onPressed: () {
                _savePost(user);
                //_uploadImages();
              },
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
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
