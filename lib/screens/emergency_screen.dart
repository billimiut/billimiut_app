import 'package:billimiut_app/screens/my_page_screen.dart';
import 'package:flutter/material.dart';
import 'package:billimiut_app/screens/post_writing_screen.dart';
import 'package:billimiut_app/screens/post_info_screen.dart';
import 'package:billimiut_app/screens/search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:billimiut_app/providers/user.dart';
import 'package:billimiut_app/providers/posts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  _EmergencyScreenState createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final List<String> regions = ['율전동', '지역2', '지역3'];
  String selectedRegion = '율전동';
  int _selectedButtonIndex = 0;
  final int _currentIndex = 1;
  String _sortCriteria = 'time'; // 기본 정렬 기준을 'time'으로 설정

  ImageProvider<Object> loadImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      Uri dataUri = Uri.parse(imageUrl);
      if (dataUri.scheme == "data") {
        return MemoryImage(base64Decode(dataUri.data!.contentAsString()));
      } else if (dataUri.isAbsolute) {
        return NetworkImage(imageUrl);
      }
    }
    return const AssetImage('assets/no_image.png');
  }

  String loadLocation(String? location) {
    if (location != null && location.isNotEmpty) {
      return location;
    } else {
      return '위치정보 없음';
    }
  }

  String formatDate(dynamic timestamp) {
    if (timestamp != null) {
      print('timestamp type: ${timestamp.runtimeType}');
      DateTime date;
      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else if (timestamp is String) {
        date = DateTime.parse(timestamp);
      } else {
        return '날짜정보 없음';
      }
      return DateFormat('MM/dd HH:mm').format(date);
    } else {
      return '날짜정보 없음';
    }
  }

  Future<void> fetchFilteredPosts(String filter, Posts posts) async {
    var apiEndPoint = dotenv.get("API_END_POINT");
    // 필터를 경로 파라미터로 사용하고, posts 리스트를 바디에 포함시켜 보냄
    var filterRequest = Uri.parse('$apiEndPoint/post/filter/$filter');

    try {
      // List<dynamic> 데이터를 JSON으로 직렬화
      String jsonData = jsonEncode(posts.mainPosts);

      // HTTP POST 요청 보내기
      var filterResponse = await http.post(
        filterRequest,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonData, // 데이터를 본문으로 전송
      );

      // Response 바디 디코딩
      var filterData = jsonDecode(utf8.decode(filterResponse.bodyBytes));
      print(filterData);

      setState(() {
        if (filter == "ing")
          _sortCriteria = "time";
        else
          _sortCriteria = filter;
        posts.setAllPosts(filterData);
      });
    } catch (e) {
      print("There was a problem with the filter_post request: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    Posts posts = Provider.of<Posts>(context);

    // 각 페이지를 정의한 리스트
    List<Widget> pages = [
      Container(), // 홈 페이지
      const EmergencyScreen(), // 긴급 페이지
      const Center(child: Text('채팅 페이지')), // 채팅 페이지
      const MyPage(), // 마이페이지
      const PostWritingScreen(), //글쓰기 페이지
    ];

    // 홈 페이지의 내용을 정의합니다.
    pages[1] = Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                user.dong.isEmpty ? '현위치 탐색 중..' : user.dong,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.search,
                  size: 30.0,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SearchScreen()),
                  );
                },
              ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(width: 16),
            //전체
            _buildButton(0, '전체', () {
              _sortCriteria = "time";
              posts.setMainPosts(posts.nearbyPosts);
            }),
            const SizedBox(width: 5),
            // 빌림 버튼
            _buildButton(1, '빌림', () {
              _sortCriteria = "time";
              posts.setMainPosts(posts.getBorrowedPosts());
            }),
            const SizedBox(width: 5),
            // 빌려줌 버튼
            _buildButton(2, '빌려줌', () {
              _sortCriteria = "time";
              posts.setMainPosts(posts.getLendPosts());
            }),
          ],
        ),

        const SizedBox(height: 10), // 버튼과 공지 사이의 간격

        Padding(
          padding: const EdgeInsets.only(
              left: 16.0, top: 10.0), // 텍스트의 왼쪽과 위쪽에 패딩 추가
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    '내 주위 상품',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8C8C8C),
                    ),
                  ),
                  const SizedBox(width: 5),
                  PopupMenuButton<int>(
                    icon: const Icon(
                      Icons.tune,
                      color: Colors.black54,
                    ),
                    onSelected: (value) {
                      if (value == 1) {
                        // 거리순 정렬
                        fetchFilteredPosts("distance", posts);
                      } else if (value == 2) {
                        // '게시중' 필터
                        fetchFilteredPosts("ing", posts);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 1,
                        child: ListTile(
                          leading: Icon(Icons.filter_1),
                          title: Text('거리순'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 2,
                        child: ListTile(
                          leading: Icon(Icons.filter_2),
                          title: Text('게시중'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(
                color: Color(0xFFF4F4F4), // 색상 코드 지정
              ),
            ],
          ),
        ),
        Flexible(
          child: Consumer<Posts>(
            builder: (context, posts, child) {
              List<Map<String, dynamic>> sortedPosts =
                  List.from(posts.allPosts);
              if (_sortCriteria == 'time') {
                sortedPosts
                    .sort((a, b) => b['post_time'].compareTo(a['post_time']));
              }
              if (posts.allPosts.isEmpty) {
                return const Center(child: Text('데이터가 없습니다.'));
              }

              return ListView.builder(
                itemCount: sortedPosts
                    .where((post) => post['emergency'] == true)
                    .length,
                itemBuilder: (context, index) {
                  var emergencyPosts = sortedPosts
                      .where((post) => post['emergency'] == true)
                      .toList();
                  var post = emergencyPosts[index];
                  bool isCompleted = post['status'] == '종료';
                  var addressLengthLimit = 25; // 길이 제한을 원하는 값으로 설정하세요.
                  var nameAndAddress = post['detail_address']; // 카카오맵으로 바꾸면 변경
                  //     post['name'] != null && post['name'].isNotEmpty
                  //         ? post['name'] + " " + post['detail_address']
                  //         : post['detail_address'];
                  var address = nameAndAddress.length <= addressLengthLimit
                      ? nameAndAddress
                      : post['detail_address'];

                  var priceLengthLimit = 5; // 길이 제한을 원하는 값으로 설정하세요.
                  var price = post['price'] == 0 ? '나눔' : '${post['price']}';

                  if (price != '나눔' && price.length > priceLengthLimit) {
                    price = '${price.substring(0, priceLengthLimit)}+';
                  }
                  var dateRange =
                      '${formatDate(post['start_date'])} ~ ${formatDate(post['end_date'])}';
                  var finalString = "${price.padRight(11)} $dateRange";
                  return Stack(
                    children: [
                      Column(
                        children: <Widget>[
                          ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailPage(
                                    docId: post['post_id'],
                                  ),
                                ),
                              );
                            },
                            title: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFFF4F4F4),
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15.0),
                                      child: Image(
                                        image: loadImage(
                                            post['image_url'].isNotEmpty
                                                ? post['image_url'][0]
                                                : null),
                                        width: 73,
                                        height: 73,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              post['map']
                                                  ? loadLocation(address) +
                                                      " (" +
                                                      post['distance']
                                                          .toString() +
                                                      "m)"
                                                  : loadLocation(address),
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 11.0,
                                                color: Color(0xFF8c8c8c),
                                              ),
                                            ),
                                            if (post['emergency'] == true)
                                              const Icon(
                                                Icons.notification_important,
                                                color: Colors.red,
                                                size: 20.0,
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 2.0),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 24.0),
                                          child: Text(
                                            post['title'],
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 15.0,
                                              color: Color(0xFF565656),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10.0),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              finalString,
                                              style: const TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.red,
                                              ),
                                            ),
                                            if (post['female'] == true)
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(right: 4.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.personDress,
                                                  color: Colors.pink,
                                                  size: 20.0,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(
                            color: Color(0xFFF4F4F4),
                            height: 1.0,
                          ),
                        ],
                      ),
                      if (isCompleted)
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: () {
                              // 종료된 게시물이어도 블러처리되어 있지만 상세 페이지로 이동할 수 있어야 합니다.
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailPage(
                                    docId: post['post_id'],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );

    return Scaffold(
      body: SafeArea(
        child: pages[_currentIndex],
      ),
    );
  }

  Widget _buildButton(int index, String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
          if (_selectedButtonIndex == index) {
            return const Color(0xFFFFB900); // 선택된 버튼의 배경색
          }
          return Colors.grey; // 선택되지 않은 버튼의 배경색
        }),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0), // 버튼의 모서리를 둥글게
          ),
        ),
      ),
      onPressed: () {
        setState(() {
          _selectedButtonIndex = index; // 버튼이 눌렸을 때 선택된 버튼의 인덱스를 업데이트합니다.
          onPressed(); // Firestore의 데이터를 업데이트하는 코드를 실행합니다.
        });
      },
      child: Text(
        text,
        style: const TextStyle(color: Colors.white), // 글씨색을 흰색으로 변경
      ),
    );
  }
}
