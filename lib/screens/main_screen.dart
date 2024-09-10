import 'package:billimiut_app/widgets/postList.dart';
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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:billimiut_app/providers/user.dart';
import 'package:billimiut_app/providers/posts.dart';
import 'dart:convert';
import 'package:billimiut_app/screens/emergency_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getCurrentLocation(); // 현재 위치 가져오기
      Posts posts = Provider.of<Posts>(context, listen: false);
      fetchPosts(posts); // 게시물 데이터를 가져오는 메서드를 호출합니다.
    });
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

              if (sortedPosts.isEmpty) {
                return const Center(child: Text('No data'));
              }

              // _sortCriteria에 따라 정렬
              print("***sortCriteria***");
              print(_sortCriteria);
              if (_sortCriteria == 'time') {
                 sortedPosts.sort((a, b) {
                var timeA = a['post_time'];
                var timeB = b['post_time'];

                DateTime dateA;
                DateTime dateB;

                // Firestore Timestamp인 경우 처리
                if (timeA is Timestamp) {
                  dateA = timeA.toDate();
                } else if (timeA is String) {
                  dateA = DateTime.parse(timeA);
                } else {
                  dateA = DateTime.now(); // 만약 데이터가 없으면 현재 시간으로 설정
                }

                if (timeB is Timestamp) {
                  dateB = timeB.toDate();
                } else if (timeB is String) {
                  dateB = DateTime.parse(timeB);
                } else {
                  dateB = DateTime.now(); // 만약 데이터가 없으면 현재 시간으로 설정
                }

                // 내림차순 정렬
                return dateB.compareTo(dateA);
              });
              }              

              return ListView.builder(
                itemCount: sortedPosts.length,
                itemBuilder: (context, index) {
                  var post = sortedPosts[index];

                  return PostList(
                    post: post,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailPage(docId: post['post_id']),
                        ),
                      );
                    },
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
