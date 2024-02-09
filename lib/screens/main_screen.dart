import 'package:billimiut_app/screens/mypage_screen.dart';
import 'package:flutter/material.dart';
import 'package:billimiut_app/screens/post_writing_screen.dart';
import 'package:billimiut_app/screens/post_info_screen.dart';
import 'package:billimiut_app/screens/search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:billimiut_app/providers/user.dart';
import 'package:billimiut_app/providers/posts.dart';
import 'dart:convert';

//import 'package:flutter_icons/flutter_icons.dart';

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
  /*
  Stream<QuerySnapshot> _stream =
      FirebaseFirestore.instance.collection('posts').snapshots();
  */
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

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    Posts posts = Provider.of<Posts>(context);

    // 각 페이지를 정의한 리스트
    List<Widget> pages = [
      Container(), // 홈 페이지
      const Center(child: Text('긴급 페이지')), // 긴급 페이지
      const Center(child: Text('채팅 페이지')), // 채팅 페이지
      const MyPage(), // 마이페이지
      const PostWritingScreen(), //글쓰기 페이지
    ];

    // 홈 페이지의 내용을 정의합니다.
    pages[0] = Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButton<String>(
                value: selectedRegion,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedRegion = newValue!;
                  });
                },
                items: regions.map<DropdownMenuItem<String>>((String value) {
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
              ),
              IconButton(
                icon: const Icon(
                  Icons.search,
                  size: 30.0,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchScreen()),
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
              posts.setAllPosts(posts.originPosts);
            }),
            const SizedBox(width: 10),
            // 빌림 버튼
            _buildButton(1, '빌림', () {
              posts.setAllPosts(posts.getBorrowedPosts());
            }),
            const SizedBox(width: 10),
            // 빌려줌 버튼
            _buildButton(2, '빌려줌', () {
              posts.setAllPosts(posts.getLendPosts());
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
                  // Marquee 위젯을 Expanded 위젯으로 감싸 나머지 공간을 채우도록 함
                  child: Marquee(
                    text: "'소프트닌자쓰'님이 '제2공학관'에서 '생리대'가 필요합니다.",
                    style: const TextStyle(
                        color: Colors.black, fontSize: 14), // 텍스트 색상
                    velocity: 30,
                    blankSpace: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 16.0, top: 10.0), // 텍스트의 왼쪽과 위쪽에 패딩 추가
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '내 주위 상품',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8C8C8C),
                ),
              ),
              Divider(
                color: Color(0xFFF4F4F4), // 색상 코드 지정
              ),
            ],
          ),
        ),
        Expanded(
          child: Consumer<Posts>(
            builder: (context, posts, child) {
              if (posts.allPosts.isEmpty) {
                return const Center(child: Text('No data'));
              }

              return ListView.builder(
                itemCount: posts.allPosts.length,
                itemBuilder: (context, index) {
                  var post = posts.allPosts[index];
                  return Column(
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          loadLocation(
                                              post['locationData']['name']),
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
                                      padding:
                                          const EdgeInsets.only(right: 24.0),
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
                                          '${post['money']}원     ${formatDate(post['start_date'])} ~ ${formatDate(post['end_date'])}',
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
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 70.0), // 하단 마진 추가
        child: FloatingActionButton(
          backgroundColor: const Color(0xFFFFB900),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ), // '+' 아이콘 설정
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PostWritingScreen()),
            );
          },
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endDocked, // 버튼 위치 설정
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
