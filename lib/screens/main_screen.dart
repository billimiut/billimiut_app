import 'package:flutter/material.dart';
import 'package:billimiut_app/screens/post_writing_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<String> regions = ['율전동', '지역2', '지역3'];
  String selectedRegion = '율전동';

  int _currentIndex = 2;

  ImageProvider<Object> loadImage(String? imageUrl) {
    if (imageUrl != null && Uri.parse(imageUrl).isAbsolute) {
      return NetworkImage(imageUrl);
    } else {
      return AssetImage('assets/no_image.png');
    }
  }

  String loadLocation(String? location) {
    if (location != null && location.isNotEmpty) {
      return location;
    } else {
      return '위치정보 없음';
    }
  }

  String formatDate(Timestamp? timestamp) {
    if (timestamp != null) {
      DateTime date = timestamp.toDate();
      return DateFormat('yyyy-MM-dd').format(date); // 원하는 형식으로 날짜를 변환
    } else {
      return '날짜정보 없음';
    }
  }

  @override
  Widget build(BuildContext context) {
    // 각 페이지를 정의한 리스트
    List<Widget> _pages = [
      Center(child: Text('긴급 페이지')), // 긴급 페이지
      Center(child: Text('채팅 페이지')), // 채팅 페이지
      Container(), // 홈 페이지
      PostWritingScreen(), //글쓰기 페이지
      Center(child: Text('마이페이지')), // 마이페이지
    ];
    // 홈 페이지의 내용을 정의합니다.
    _pages[2] = Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: DropdownButton<String>(
              value: selectedRegion,
              onChanged: (String? newValue) {
                setState(() {
                  selectedRegion = newValue!;
                });
              },
              items: regions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('posts').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Something went wrong'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.data == null) {
                return Center(child: Text('No data'));
              }

              return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Image(
                              image: loadImage(data['imageUrl']),
                              width: 70,
                              height: 70), // 이미지
                          SizedBox(width: 10.0), // 이미지와 텍스트 사이의 간격
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(loadLocation(data['location']), // 위치
                                    style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey[800])),
                                SizedBox(height: 5.0),
                                Text(
                                  data['title'], // 제목
                                  style:
                                      TextStyle(fontSize: 18.0), // 제목 글자 크기 조절
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  '${data['money']}원, ${formatDate(data['startDate'])} ~ ${formatDate(data['endDate'])}', // 돈, 시작 날짜 ~ 종료 날짜
                                  style: TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.red), // 텍스트 색상을 빨간색으로 변경
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('빌리미웃'),
        centerTitle: true,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.blue,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: '긴급',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: '채팅',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.create),
            label: '글쓰기',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '마이페이지',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
