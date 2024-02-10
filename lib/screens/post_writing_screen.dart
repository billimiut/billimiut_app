import 'dart:io';
import 'dart:convert';
import 'package:billimiut_app/providers/place.dart';
import 'package:billimiut_app/providers/user.dart';
import 'package:billimiut_app/widgets/borrow_lend_tab.dart';
import 'package:billimiut_app/widgets/image_uploader.dart';
import 'package:billimiut_app/widgets/location_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../widgets/date_time_picker.dart';
import '../widgets/post_writing_text.dart';
import '../models/post.dart';
import 'package:provider/provider.dart';
import '../providers/image_list.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

class PostWritingScreen extends StatefulWidget {
  const PostWritingScreen({super.key});

  @override
  State<PostWritingScreen> createState() => _PostWritingScreenState();
}

class _PostWritingScreenState extends State<PostWritingScreen> {
  var apiEndPoint = dotenv.get("API_END_POINT");

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
  bool _isImageUploaded = false;
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
  String selectedCategory = "카테고리 선택";

  @override
  void dispose() {
    _titleController.dispose();
    _itemController.dispose();
    _moneyController.dispose();
    _descriptionController.dispose();
    _placeController.dispose();
    super.dispose();
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

  void _savePost(User user, Place place, ImageList imageList) async {
    final imageList = Provider.of<ImageList>(context, listen: false);
    var request =
        http.MultipartRequest('POST', Uri.parse('$apiEndPoint/upload_image'));

    for (var imageFile in imageList.selectedImages) {
      print(imageFile);

      // 확장자 추출
      var extension = path.extension(imageFile.path).toLowerCase();

      // MIME 타입 설정
      MediaType contentType;
      if (extension == '.jpg' || extension == '.jpeg') {
        contentType = MediaType('image', 'jpeg');
      } else if (extension == '.png') {
        contentType = MediaType('image', 'png');
      } else {
        print('Unsupported image format: $extension');
        continue;
      }

      request.files.add(await http.MultipartFile.fromPath(
        'images', // 서버에서 기대하는 파일 키
        imageFile.path,
        contentType: contentType,
      ));
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print("Images uploaded");
        print("Response body: ${response.body}");
        imageList.setImageUrls(data["urls"]);
        setState(() {
          _isImageUploaded = true;
        });

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
        var apiEndPoint = dotenv.get("API_END_POINT");
        var requestAddPost = Uri.parse('$apiEndPoint/add_post');
        var bodyAddPost = {
          "user_id": user.userId,
          "post": {
            "post_id": "",
            "nickname": user.nickname,
            "title": _titleController.text,
            "item": _itemController.text,
            "category": selectedCategory,
            "image_url": imageList.imageUrls,
            "money": int.parse(_moneyController.text),
            "borrow": _borrow,
            "description": _descriptionController.text,
            "emergency": _emergency,
            "start_date": DateFormat('yyyy-MM-dd HH:mm:ss').format(_startDate),
            "end_date": DateFormat('yyyy-MM-dd HH:mm:ss').format(_endDate),
            "location_id": "",
            "female": _female,
            "status": "",
            "borrower_user_id": "",
            "lender_user_id": "",
          },
          "location": {
            "location_id": "",
            "map": {
              "latitude": place.latitude,
              "longitude": place.longitude,
            },
            "name": "",
            "address": place.address,
            "detail_address": _placeController.text,
            "dong": "",
          }
        };

        print(jsonEncode(bodyAddPost));

        http
            .post(
          requestAddPost,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(bodyAddPost),
        )
            .then((responseAddPost) {
          var dataAddPost = jsonDecode(responseAddPost.body);
          print("add_post response.body: $dataAddPost");
          imageList.setImageUrls([]);
          Navigator.pop(context);
        }).catchError((error) {
          // 에러 처리 코드
          print("add post failed: $error");
        });
      } else {
        print("Upload failed with status: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageList = Provider.of<ImageList>(context, listen: false);
    User user = Provider.of<User>(context);
    Place place = Provider.of<Place>(context);

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
            GestureDetector(
              onTap: () {
                setState(() {
                  _isClicked = !_isClicked;
                });
              },
              child: Container(
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
                    const Icon(
                      Icons.arrow_drop_down,
                      size: 32,
                      color: Color(0xFFFFB900),
                    ),
                  ],
                ),
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
            const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PostWritingText(text: "위치"),
                SizedBox(
                  width: 5,
                ),
                Text(
                  "지도를 탭하여 거래 장소를 선택한 후, 거래 장소명을 작성해주세요.",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
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
              controller: _placeController,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFFF4F4F4),
                border: InputBorder.none,
                hintText: '거래 장소에 대한 구체적인 설명을 입력하세요',
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
                _savePost(user, place, imageList);
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
