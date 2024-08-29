import 'dart:io';
import 'dart:convert';
import 'package:billimiut_app/providers/place.dart';
import 'package:billimiut_app/providers/posts.dart';
import 'package:billimiut_app/providers/select.dart';
import 'package:billimiut_app/providers/user.dart';
import 'package:billimiut_app/widgets/borrow_lend_tab.dart';
import 'package:billimiut_app/widgets/categories_drop_down.dart';
import 'package:billimiut_app/widgets/custom_alert_dialog.dart';
import 'package:billimiut_app/widgets/image_uploader.dart';
import 'package:billimiut_app/widgets/location_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../widgets/date_time_picker.dart';
import '../widgets/post_writing_text.dart';
import 'package:provider/provider.dart';
import '../providers/image_list.dart';
import 'package:http_parser/http_parser.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class PostWritingScreen extends StatefulWidget {
  const PostWritingScreen({super.key});

  @override
  State<PostWritingScreen> createState() => _PostWritingScreenState();
}

class _PostWritingScreenState extends State<PostWritingScreen> {
  var apiEndPoint = dotenv.get("API_END_POINT");

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  bool _borrow = true;
  bool _female = false;
  bool _emergency = true;
  bool map = false;

  List<String> categories = [
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

  @override
  void dispose() {
    _titleController.dispose();
    _itemController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  String cleanResponse(String response) {
    // 특수문자와 불필요한 공백 제거
    response = response.replaceAll(RegExp(r'[^\w\s가-힣]'), '');
    response = response.trim();
    return response;
  }

  Future<Map<String, String?>> generateItemCategoryAndDescription(
      String title, String location) async {
    final openaiApiKey =
        dotenv.get("OPENAI_API_KEY", fallback: "API_KEY_NOT_FOUND");

    var url = Uri.parse("https://api.openai.com/v1/chat/completions");
    var body = jsonEncode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {
          "role": "system",
          "content": """당신은 주어진 제목에서 빌림 품목과 카테고리를 추출하고, 
        제목과 위치를 기반으로 내용을 작성하는 어시스턴트입니다. 
        빌림품목은 항상 한단어로 추출하고,
        카테고리는 항상 아래 목록 중 하나로만 선택하세요:
        '디지털기기', '생활가전', '가구/인테리어', '여성용품', 
        '일회용품', '생활용품', '주방용품', '캠핑용품', 
        '애완용품', '스포츠용품', '공부용품', '놀이용품', 
        '무료나눔', '의류', '공구', '식물'
        응답은 다음과 같은 형식으로 제공하세요:
        item: "물품명", category: "카테고리명", description: "위치에서 물품을 빌려주세요."
        """
        },
        {
          "role": "user",
          "content":
              "제목: '$title'. 위치: '$location'. 이 정보를 바탕으로 빌림 품목, 적절한 카테고리, 그리고 제목과 위치를 기반으로 빌림,빌려줌 혹은 나눔하는 내용을 생성해 주세요."
        }
      ],
      "max_tokens": 150,
    });

    var headers = {
      'Authorization': 'Bearer $openaiApiKey',
      'Content-Type': 'application/json',
    };

    try {
      var response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        var content = jsonResponse['choices'][0]['message']['content'].trim();
        final pattern = RegExp(
            r'item:\s*"([^"]+)",\s*category:\s*"([^"]+)",\s*description:\s*"([^"]+)"');
        final match = pattern.firstMatch(content);
        print(match);

        if (match != null) {
          final extractedItem = match.group(1)?.trim();
          final category = match.group(2)?.trim();
          final description = match.group(3)?.trim();

          return {
            'item': extractedItem,
            'category': category,
            'description': description,
          };
        } else {
          print('No match found in the content.');
          return {
            'item': null,
            'category': null,
            'description': null,
          };
        }
      } else {
        print("Failed to generate content: ${response.statusCode}");
        print(response.body);
        return {
          'item': null,
          'category': null,
          'description': null,
        };
      }
    } catch (e) {
      print("Error occurred: $e");
      return {
        'item': null,
        'category': null,
        'description': null,
      };
    }
  }

  void _savePost(User user, Place place, ImageList imageList, Posts posts,
      Select select) async {
    try {
      int intValue = int.parse(_priceController.text);
      // 정상적으로 정수로 변환된 경우 intValue 사용
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // 모달 내용 구성
          return CustomAlertDialog(
              titleText: '저장 실패',
              contentText: '가격에 올바른 값을 입력해주세요.\n(정수값 입력)',
              actionWidgets: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB900),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ]);
        },
      );
      // 정수로 변환에 실패한 경우
      return;
    }

    // 카테고리 선택 안 한 경우
    if (select.selectedIndex == -1 || select.selectedCategory == "카테고리 선택") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // 모달 내용 구성
          return CustomAlertDialog(
              titleText: '저장 실패',
              contentText: '카테고리를 선택해주세요.',
              actionWidgets: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB900),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ]);
        },
      );
      return;
    }

    // 필수 값을 입력하세요 모달창 띄우기
    if (_titleController.text.isEmpty ||
        _itemController.text.isEmpty ||
        _placeController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // 모달 내용 구성
          return CustomAlertDialog(
              titleText: '저장 실패',
              contentText: '필수 값들을 입력해주세요.',
              actionWidgets: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB900),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ]);
        },
      );
      return;
    }

    var postTime = DateTime.now();

    Duration difference = postTime.difference(_startDate).abs();

    print(difference.inMinutes);

    if (difference.inMinutes <= 30) {
      setState(() {
        _emergency = true;
      });
    } else {
      setState(() {
        _emergency = false;
      });
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    user.setLatitude(position.latitude);
    user.setLongitude(position.longitude);

    final imageList = Provider.of<ImageList>(context, listen: false);

    var fieldData = {
      "address": place.address,
      "detail_address": _placeController.text,
      "dong": "율전동",
      "borrow": _borrow,
      "borrower_uuid": _borrow ? user.uuid : null,
      "category": select.selectedCategory,
      "title": _titleController.text,
      "description": _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : "",
      "emergency": _emergency,
      "start_date": _startDate.toString(),
      "end_date": _endDate.toString(),
      "female": _female,
      "item": _itemController.text,
      "lender_uuid": _borrow ? null : user.uuid,
      "map_coordinate": {
        "latitude": place.latitude,
        "longitude": place.longitude,
      },
      "price": int.parse(_priceController.text),
      "post_time": postTime.toString(),
      "status": "게시",
      "map": map,
    };

    print("fieldData: $fieldData");

    var uri = Uri.parse('$apiEndPoint/post');

    var request = http.MultipartRequest('POST', uri)
      ..headers['accept'] = 'application/json'
      ..headers['Content-Type'] = 'multipart/form-data'
      ..fields['post'] = jsonEncode(fieldData);

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
          'image_file', // 서버에서 기대f 하는 파일 키
          imageFile.path,
          contentType: contentType,
        ));
      }
    } else {}

    try {
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonData = json.decode(responseData);
      print("jsonData: $jsonData");
      posts.addOriginPosts(jsonData);
      Navigator.pop(context);
    } catch (e) {
      print('/add_post error: $e');
    }
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
            const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PostWritingText(text: "제목"),
                SizedBox(
                  width: 4.0,
                ),
                Text(
                  "*",
                  style: TextStyle(
                    fontSize: 16,
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
            const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PostWritingText(text: "위치"),
                SizedBox(
                  width: 4.0,
                ),
                Text(
                  "*",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                SizedBox(
                  width: 4,
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
            const Text(
              "예) 성균관대학교 기숙사 예관 3층 자판기 앞",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
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
              height: 8,
            ),
            Align(
              alignment: Alignment.centerLeft, // 버튼을 가운데로 정렬
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: map ? Colors.red : const Color(0xff007DFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      map = !map;
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Row의 크기를 자식의 크기에 맞게 설정
                    children: [
                      const Icon(
                        Icons.map, // 지도 아이콘
                        color: Color(0xFFF4F4F4), // 아이콘 색상
                        size: 16, // 아이콘 크기
                      ),
                      const SizedBox(width: 8), // 아이콘과 텍스트 사이의 간격
                      Text(
                        map ? '지도 삭제' : '지도 추가',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF4F4F4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            if (map) const LocationPicker(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const PostWritingText(text: "빌림 품목"),
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
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    final result = await generateItemCategoryAndDescription(
                        _titleController.text, _placeController.text);
                    print(result);
                    if (result['item'] != null &&
                        result['category'] != null &&
                        result['description'] != null) {
                      setState(() {
                        _itemController.text = result['item']!;
                        final selectedIndex =
                            categories.indexOf(result['category']!);
                        if (selectedIndex != -1) {
                          // AI가 생성한 카테고리가 categories 리스트에 있는 경우
                          select.setSelectedIndex(selectedIndex);
                          select.setSelectedCategory(result['category']!);
                        } else {
                          // AI가 생성한 카테고리가 categories 리스트에 없는 경우 초기 상태로 유지
                          select.setSelectedIndex(-1); // 초기 상태로 유지
                          select.setSelectedCategory('카테고리 선택'); // 초기 카테고리 설정
                        }
                        _descriptionController.text = result['description']!;
                      });
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomAlertDialog(
                            titleText: '추출 실패',
                            contentText: 'AI를 통해 빌림 품목, 카테고리, 내용 생성을 할 수 없습니다.',
                            actionWidgets: [
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFB900),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    '확인',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: const Text(
                    "AI로 작성하기",
                    style: TextStyle(
                      color: Color(0xff007DFF),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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
              controller: _itemController,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFFF4F4F4),
                border: InputBorder.none,
                hintText: '품목을 입력하세요.',
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
                          size: 24.0, color: Color(0xff007DFF)),
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
              controller: _priceController,
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
                  initialText: "시작 날짜 및 시간",
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
            const SizedBox(height: 8),
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
                  '저장',
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
