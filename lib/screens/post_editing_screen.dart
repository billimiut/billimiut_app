import 'dart:io';
import 'dart:convert';
import 'package:billimiut_app/providers/place.dart';
import 'package:billimiut_app/providers/posts.dart';
import 'package:billimiut_app/providers/select.dart';
import 'package:billimiut_app/providers/user.dart';
import 'package:billimiut_app/widgets/borrow_lend_tab.dart';
import 'package:billimiut_app/widgets/categories_drop_down.dart';
import 'package:billimiut_app/screens/my_posts_screen.dart';
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

class PostEditingScreen extends StatefulWidget {
  final String? postId;
  final Map? info;

  const PostEditingScreen({super.key, this.postId, this.info});

  @override
  State<PostEditingScreen> createState() => _PostEditingScreenState();
}

class _PostEditingScreenState extends State<PostEditingScreen> {
  var apiEndPoint = dotenv.get("API_END_POINT");

  late TextEditingController _titleController;
  late TextEditingController _itemController;
  late TextEditingController _moneyController;
  late TextEditingController _descriptionController;
  late TextEditingController _placeController;
  late String _postId;
  late DateTime _startDate;
  late DateTime _endDate;
  late String _location;
  late var _borrow;
  late List<String> _imageUrls = [];
  late bool _female;
  late bool _emergency;
  late bool _isClicked;
  late bool _isImageUploaded;
  List<String> selectedImages = [];
  late List<String> categories = [
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
    '공부용품',
    '놀이용품',
    '무료나눔',
    '의류',
    '공구',
    '식물',
  ];
  int selectedIndex = -1;
  String selectedCategory = "카테고리 선택";

  @override
  void initState() {
    super.initState();
    print('info: ${widget.info}');
    if (widget.info != null) {
      _postId = widget.info?['post_id'] ?? "";
      _titleController = TextEditingController(text: widget.info?['title']);
      _itemController = TextEditingController(text: widget.info?['item']);
      _moneyController =
          TextEditingController(text: widget.info?['money'].toString());
      _descriptionController =
          TextEditingController(text: widget.info?['description']);
      _placeController =
          TextEditingController(text: widget.info?['detail_address']);

      _startDate = widget.info?['start_date'] != null
          ? DateTime.parse(widget.info?['start_date'])
          : DateTime.now();
      _endDate = widget.info?['end_date'] != null
          ? DateTime.parse(widget.info?['end_date'])
          : DateTime.now();
      _location = widget.info?['name'] ?? '';
      _borrow = widget.info?['borrow'] ?? true;
      _imageUrls = widget.info?['image_url'] is List &&
              (widget.info?['image_url'] as List).isNotEmpty
          ? List<String>.from(widget.info?['image_url'] as List)
          : [];
      if (widget.info != null && widget.info?['category'] != null) {
        selectedCategory = widget.info?['category'];
        selectedIndex = categories.indexOf(selectedCategory);
      }
      _female = widget.info?['female'] ?? false;
      _emergency = widget.info?['emergency'] ?? false;
      _isClicked = widget.info?['isClicked'] ?? false;
      _isImageUploaded = widget.info?['isImageUploaded'] ?? false;
    } else {
      _titleController = TextEditingController();
      _itemController = TextEditingController();
      _moneyController = TextEditingController();
      _descriptionController = TextEditingController();
      _placeController = TextEditingController();

      _startDate = DateTime.now();
      _endDate = DateTime.now();
      _location = '';
      _borrow = true;
      _imageUrls = [];
      _female = false;
      selectedCategory = '';
      _emergency = false;
      _isClicked = false;
      _isImageUploaded = false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _itemController.dispose();
    _moneyController.dispose();
    _descriptionController.dispose();
    _placeController.dispose();
    super.dispose();
  }

//

  void _savePost(User user, Place place, ImageList imageList, Posts posts,
      Select select) async {
    final imageList = Provider.of<ImageList>(context, listen: false);

    var request = http.MultipartRequest(
        'PUT', Uri.parse('$apiEndPoint/edit_post?post_id=${widget.postId}'));

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

    var fieldData = {
      "post_id": widget.postId,
      "title": _titleController.text,
      "item": _itemController.text,
      "category": select.selectedCategory,
      "money": int.parse(_moneyController.text),
      "borrow": _borrow,
      "description": _descriptionController.text,
      "start_date": _startDate,
      "end_date": _endDate,
      "female": _female,
      "address": place.address,
      "detail_address": _placeController.text,
      "name": "",
      "map_latitude": place.latitude,
      "map_longitude": place.longitude,
      "dong": "",
      "deleted_images": imageList.deletedImages,
    };

    print("fieldData: $fieldData");

    for (var entry in fieldData.entries) {
      request.fields[entry.key] = entry.value.toString();
    }

    if (imageList.selectedImages.isNotEmpty) {
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
          'images', // 서버에서 기대f 하는 파일 키
          imageFile.path,
          contentType: contentType,
        ));
      }
    } else {}

    request.send().then((response) {
      response.stream.bytesToString().then((responseData) {
        var jsonData = json.decode(responseData);
        print(jsonData);
        posts.updatePost(jsonData);
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyPostsScreen()),
        );
      }).catchError((e) {
        print('/edit_post error: $e');
      });
    }).catchError((e) {
      print('/edit_post error: $e');
    });

    /*
    try {
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonData = json.decode(responseData);
      print(jsonData);
      posts.updatePost(jsonData);
      Navigator.pop(context);
    } catch (e) {
      print('/edit_post error: $e');
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    final imageList = Provider.of<ImageList>(context, listen: false);
    User user = Provider.of<User>(context);
    Place place = Provider.of<Place>(context);
    Posts posts = Provider.of<Posts>(context);
    Select select = Provider.of<Select>(context);

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
            const SizedBox(
              height: 8,
            ),
            const CategoriesDropDown(),
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
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                DateTimePicker(
                  initialText: _startDate != null
                      ? DateFormat('yyyy-MM-dd HH:mm').format(_startDate)
                      : "시작 날짜 및 시간",
                  onDateSelected: (DateTime selectedDate) {
                    _startDate = selectedDate;
                  },
                ),
                const SizedBox(
                  width: 5,
                ),
                const Text(
                  '~',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                DateTimePicker(
                  initialText: _endDate != null
                      ? DateFormat('yyyy-MM-dd HH:mm').format(_endDate)
                      : "종료 날짜 및 시간",
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
            const SizedBox(height: 8),
            ImageUploader(initialImageUrls: _imageUrls),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB900), // 버튼의 글씨 색 변경
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  '수정완료',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  _savePost(user, place, imageList, posts, select);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
