import 'package:billimiut_app/providers/image_list.dart';
import 'package:billimiut_app/providers/place.dart';
import 'package:billimiut_app/providers/select.dart';
import 'package:billimiut_app/screens/chatting_list.dart';
import 'package:billimiut_app/screens/my_page_screen.dart';
import 'package:billimiut_app/widgets/scrolling.dart';
import 'package:flutter/material.dart';
import 'package:billimiut_app/screens/post_writing_screen.dart';
import 'package:billimiut_app/screens/post_info_screen.dart';
import 'package:billimiut_app/screens/search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:billimiut_app/providers/user.dart';
import 'package:billimiut_app/providers/posts.dart';
import 'dart:convert';
import 'package:billimiut_app/screens/emergency_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<String> regions = ['율전동', '지역2', '지역3'];
  String selectedRegion = '율전동';
  int _selectedButtonIndex = 0;
  int _currentIndex = 0;
  double _latitude = 0.0;
  double _longitude = 0.0;
  String _sortCriteria = 'time'; // 기본 정렬 기준을 'time'으로 설정
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getCurrentLocation(); // 현재 위치 가져오기
      Posts posts = Provider.of<Posts>(context, listen: false);
      await fetchPosts(posts); // 게시물 데이터를 가져오는 메서드를 호출합니다.

      // 화면이 완전히 빌드된 후 스크롤 애니메이션 실행
      if (mounted) {
        setState(() {
          // 이 지점에서 스크롤을 최대로 이동
          _scrollToEnd();
        });
      }
    });
  }

  void _scrollToEnd() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 현재 위치를 가져오는 메서드
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
  }

  Future<void> fetchPosts(Posts posts) async {
    var apiEndPoint = dotenv.get("API_END_POINT");
    // var getPostsRequest = Uri.parse('$apiEndPoint/post');
    var getPostsRequest = Uri.parse(
        '$apiEndPoint/post?latitude=$_latitude&longitude=$_longitude');

    try {
      var getPostsResponse = await http
          .get(getPostsRequest, headers: {'Content-Type': 'application/json'});
      var getPostsData = jsonDecode(getPostsResponse.body);
      getPostsData = json.decode(utf8.decode(getPostsResponse.bodyBytes));
      print(getPostsData);

      posts.setOriginPosts(getPostsData);
    } catch (e) {
      print("There was a problem with the getPosts request: $e");
    }
  }

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

  String remainingTime(dynamic endDate) {
    // String 타입일 경우 DateTime으로 변환
    if (endDate is String) {
      // ISO 8601 형식의 문자열을 DateTime으로 변환
      endDate = DateTime.parse(endDate);
    }
    print("endDate = $endDate");

    final now = DateTime.now();
    print("now = $now");
    final difference = endDate.difference(now);
    print(difference);

    if (difference.isNegative) {
      return '기한종료';
    }

    if (difference.inDays > 0) {
      return '종료까지 남은 시간: ${difference.inDays}일';
    } else if (difference.inHours > 0) {
      return '종료까지 남은 시간: ${difference.inHours}시간';
    } else {
      return '종료까지 남은 시간: ${difference.inMinutes}분';
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
        if (filter == "ing") {
          _sortCriteria = "time";
        } else {
          _sortCriteria = filter;
        }
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
    Select select = Provider.of<Select>(context);
    ImageList imageList = Provider.of<ImageList>(context);
    Place place = Provider.of<Place>(context);

    print("chat list: ${user.chatList}");

    // 각 페이지를 정의한 리스트
    List<Widget> pages = [
      _buildHomePage(posts), // 홈 페이지
      const EmergencyScreen(), // 긴급 페이지
      const ChattingList(), // 채팅 페이지
      const MyPage(), // 마이페이지
      const PostWritingScreen(), //글쓰기 페이지
    ];

    return Scaffold(
      body: SafeArea(
        child: pages[_currentIndex],
      ),
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
          ? Container(
              margin:
                  const EdgeInsets.only(bottom: 60.0), // 여기서 버튼을 살짝 위로 이동시킵니다.
              child: FloatingActionButton(
                backgroundColor: const Color(0xFFFFB900),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ), // '+' 아이콘 설정
                onPressed: () async {
                  Position position = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.high,
                  );
                  select.setSelectedIndex(-1);
                  select.setSelectedCategory("카테고리 선택");
                  imageList.setSelectedImages([]);
                  imageList.setImageUrls([]);
                  user.setLatitude(position.latitude);
                  user.setLongitude(position.longitude);
                  place.setLatitude(user.latitude);
                  place.setLongitude(user.longitude);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PostWritingScreen(),
                    ),
                  );
                },
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,
        selectedItemColor: const Color(0xFFFFB900),
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30.0),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning, size: 30.0),
            label: '긴급',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat, size: 30.0),
            label: '채팅',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 30.0),
            label: '마이페이지',
          )
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0) {
            // '홈' 탭이 선택되었을 때
            _sortCriteria = "time";
            fetchPosts(posts); // 게시물을 새로고침합니다.
          }
        },
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
          onPressed();
        });
      },
      child: Text(
        text,
        style: const TextStyle(color: Colors.white), // 글씨색을 흰색으로 변경
      ),
    );
  }

  Widget _buildHomePage(Posts posts) {
    User user = Provider.of<User>(context);
    return Column(
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

              /*
              DropdownButton<String>(
                value: '율전동', // 선택된 값을 지정
                onChanged: (String? newValue) {
                  // 선택된 값이 변경될 때 호출되는 함수
                  print(newValue);
                },
                items: <String>['율전동', '지역2', '지역3']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, // 글자를 bold체로 변경
                        fontSize: 18.0,
                      ),
                    ),
                  );
                }).toList(),
              ),*/
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
        Card(
          color: Colors.grey[200], // 백그라운드 색상
          child: SizedBox(
            height: 40, // Container의 높이를 명시적으로 지정
            child: Row(
              // Marquee 위젯과 아이콘을 Row 위젯 안에 넣음
              children: [
                const Padding(
                  // 아이콘을 Padding 위젯으로 감싸 왼쪽에서 띄움
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child:
                      Icon(FontAwesomeIcons.bell, color: Colors.red), // 긴급 아이콘
                ),
                Expanded(
                  child: Builder(
                    builder: (BuildContext context) {
                      var posts = Provider.of<Posts>(context);
                      var emergencyPosts = posts.getEmergencyPosts();

                      return ListView.builder(
                        itemCount: emergencyPosts.length,
                        itemBuilder: (context, index) {
                          return SizedBox(
                            height: 50, // 높이를 적절하게 조절하세요.
                            child: ScrollingText(
                              emergencyPosts: emergencyPosts,
                              key: null,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
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

              // _sortCriteria에 따라 정렬
              print("***sortCriteria***");
              print(_sortCriteria);
              if (_sortCriteria == 'time') {
                sortedPosts
                    .sort((a, b) => b['post_time'].compareTo(a['post_time']));
              }

              if (sortedPosts.isEmpty) {
                return const Center(child: Text('데이터 준비 중..'));
              }

              return ListView.builder(
                itemCount: sortedPosts.length,
                itemBuilder: (context, index) {
                  var post = sortedPosts[index];
                  bool isCompleted = post['status'] == '종료';
                  var addressLengthLimit = 25; // 길이 제한을 원하는 값으로 설정하세요.
                  var nameAndAddress = post['detail_address']; // 카카오맵으로 바꾸면 변경
                  // post['name'] != null && post['name'].isNotEmpty
                  //     ? post['name'] + " " + post['detail_address']
                  //     : post['detail_address'];
                  var address = nameAndAddress.length <= addressLengthLimit
                      ? nameAndAddress
                      : post['detail_address'];

                  var priceLengthLimit = 5; // 길이 제한을 원하는 값으로 설정하세요.
                  var price = post['price'] == 0 ? '나눔' : '${post['price']}원';

                  if (price != '나눔' && price.length > priceLengthLimit) {
                    price = '${price.substring(0, priceLengthLimit)}+';
                  }
                  var dateRange =
                      '${formatDate(post['start_date'])} ~ ${formatDate(post['end_date'])}';
                  var endDate = post['end_date'];
                  var remainTime = remainingTime(endDate);
                  var finalString = "${price.padRight(11)} $remainTime";

                  final text = post['map']
                      ? "${loadLocation(address)} (${post['distance']}m)"
                      : loadLocation(address);
                  ScrollController itemScrollController = ScrollController();
                  void startScrolling() {
                    if (itemScrollController.hasClients) {
                      itemScrollController
                          .animateTo(
                        itemScrollController.position.maxScrollExtent,
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeInOut,
                      )
                          .then((_) {
                        // 일정 시간 후 다시 처음으로 이동하여 스크롤 반복
                        Timer(const Duration(seconds: 1), () {
                          itemScrollController
                              .animateTo(
                            0.0,
                            duration: const Duration(seconds: 2),
                            curve: Curves.easeInOut,
                          )
                              .then((_) {
                            // 스크롤이 처음으로 돌아오면 다시 스크롤 시작
                            startScrolling();
                          });
                        });
                      });
                    }
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    startScrolling(); // 초기 스크롤 시작
                  });

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
                                            SizedBox(
                                              width: 250, // 너비를 고정
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                controller:
                                                    itemScrollController,
                                                child: Text(
                                                  text,
                                                  style: const TextStyle(
                                                    fontSize: 11.0,
                                                    color: Color(0xFF8c8c8c),
                                                  ),
                                                  softWrap: false,
                                                  overflow:
                                                      TextOverflow.visible,
                                                ),
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
  }
}
