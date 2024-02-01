import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // 날짜 형식을 변경하기 위해 필요

class DetailPage extends StatelessWidget {
  final String docId; // 클릭한 리스트 아이템의 document id
  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Unknown date';
    }
    DateTime date = timestamp.toDate();
    return DateFormat('yyyy-MM-dd').format(date);
  }

  DetailPage({required this.docId});

  @override
  Widget build(BuildContext context) {
    CollectionReference posts = FirebaseFirestore.instance.collection('posts');

    return FutureBuilder<DocumentSnapshot>(
      future: posts.doc(docId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("오류가 발생했습니다: ${snapshot.error}");
        }
        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text("해당 게시물이 존재하지 않습니다.");
        }
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          DateTime startDate = data['startDate'].toDate();
          DateTime endDate = data['endDate'].toDate();
          return SingleChildScrollView(
            child: Card(
              //margin: EdgeInsets.all(20),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(data['imageUrl']), // 이미지 URL
                    SizedBox(height: 20.0),
                    Text(data['title'],
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)), // 제목
                    SizedBox(height: 10.0),
                    Text("작성자: 작성자",
                        style:
                            TextStyle(fontSize: 16, color: Colors.grey)), // 작성자
                    Divider(),
                    Text("가격: ${data['money']}원",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)), // 가격
                    SizedBox(height: 10.0),
                    Text(
                        "빌림시간: ${DateFormat('yyyy.MM.dd').format(startDate)} ~ ${DateFormat('yyyy.MM.dd').format(endDate)}",
                        style: TextStyle(fontSize: 16)), // 빌림 시간
                    Divider(),
                    Text("빌리미의 글",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Divider(),
                    Text(data['description'],
                        style: TextStyle(fontSize: 16)), // 상세 설명
                    Divider(),
                    Text("위치: ${data['location']}",
                        style: TextStyle(fontSize: 16)), // 위치
                  ],
                ),
              ),
            ),
          );
        }
        return CircularProgressIndicator(); // 데이터를 로드하는 동안 보여질 위젯
      },
    );
  }
}
