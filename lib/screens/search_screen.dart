import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("검색"),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              decoration: InputDecoration(
                labelText: "검색어를 입력하세요",
              ),
            ),
          ),
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('title',
              isGreaterThanOrEqualTo: _searchText) // 검색어를 포함하는 게시물만 필터링
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
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
                                  fontSize: 12.0, color: Colors.grey[800])),
                          SizedBox(height: 5.0),
                          Text(
                            data['title'], // 제목
                            style: TextStyle(fontSize: 18.0), // 제목 글자 크기 조절
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
    );
  }
}

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
