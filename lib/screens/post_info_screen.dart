import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // 날짜 형식을 변경하기 위해 필요
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:billimiut_app/providers/user.dart';
import 'package:billimiut_app/providers/posts.dart';

class DetailPage extends StatelessWidget {
  final String docId; // 클릭한 리스트 아이템의 document id
  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Unknown date';
    }
    DateTime date = timestamp.toDate();
    return DateFormat('yyyy-MM-dd').format(date);
  }

  const DetailPage({super.key, required this.docId});

  @override
  Widget build(BuildContext context) {
    Posts postsProvider = Provider.of<Posts>(context);
    Map<String, dynamic>? data = postsProvider.allPosts
        .firstWhere((post) => post['id'] == docId, orElse: () => null);

    if (data == null) {
      return const Scaffold(
        body: Center(
          child: Text("해당 게시물이 존재하지 않습니다."),
        ),
      );
    }

    DateTime startDate = data['start_date'].toDate();
    DateTime endDate = data['end_date'].toDate();

    Widget titleWidget = Text(
      data['title'],
      maxLines: null,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF565656),
      ),
    );

    if (data['emergency'] == true) {
      titleWidget = Row(
        children: [
          Expanded(
            child: titleWidget, // Add the title
          ),
          const SizedBox(width: 10.0), // Add space
          const Icon(Icons.notification_important,
              color: Colors.red, size: 30.0), // Add emergency icon
        ],
      );
    }

    return Stack(
      children: [
        SingleChildScrollView(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Image.network(
                    data['image_url'],
                    height: MediaQuery.of(context).size.height / 4,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage:
                                      NetworkImage('https://url.kr/t5lipd'),
                                  radius: 30,
                                ),
                                SizedBox(width: 10.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "육성재님", //data['userName'], // 작성자 이름
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF565656),
                                      ),
                                    ),
                                    Text(
                                      "율전동", //data['userLocation'], // 작성자 주소
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              alignment: Alignment.center, // 드롭다운 버튼 가운데 정렬
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F4F4),
                                border: Border.all(
                                  color: const Color(0xFFD0D0D0), // 테두리 색상 설정
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  dropdownColor: const Color(0xFFF4F4F4),
                                  value: '빌림중',
                                  style:
                                      const TextStyle(color: Color(0xFF565656)),
                                  onChanged: (String? newValue) {
                                    // Update some state
                                  },
                                  items: <String>['빌림중', '빌림완료']
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: SizedBox(
                                        height: 18.0, // 드롭다운 항목 높이 설정
                                        child: Text(value),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20.0),
                      titleWidget, // Display the title widget
                      const SizedBox(height: 10.0),
                      const Text(
                        "상세정보",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8C8C8C),
                        ),
                      ),
                      const Divider(color: Color(0xFFF4F4F4)),
                      Row(
                        children: [
                          const Expanded(
                            flex: 1,
                            child: Text(
                              '장소:',
                              style: TextStyle(
                                  fontSize: 14, color: Color(0xFF565656)),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              data['location'],
                              style: const TextStyle(
                                  fontSize: 14, color: Color(0xFF565656)),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Expanded(
                            flex: 1,
                            child: Text(
                              '빌림품목:',
                              style: TextStyle(
                                  fontSize: 14, color: Color(0xFF565656)),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              data['item'],
                              style: const TextStyle(
                                  fontSize: 14, color: Color(0xFF565656)),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Expanded(
                            flex: 1,
                            child: Text(
                              '가격:',
                              style: TextStyle(
                                  fontSize: 14, color: Color(0xFF565656)),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              '${data['money']}원',
                              style: const TextStyle(
                                  fontSize: 14, color: Color(0xFF565656)),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Expanded(
                            flex: 1,
                            child: Text(
                              '빌림시간:',
                              style: TextStyle(
                                  fontSize: 14, color: Color(0xFF565656)),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              "${DateFormat('yyyy.MM.dd HH:mm').format(startDate)} ~ ${DateFormat('yyyy.MM.dd HH:mm').format(endDate)}",
                              style: const TextStyle(
                                  fontSize: 14, color: Color(0xFF565656)),
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Color(0xFFF4F4F4)),
                      const Text(
                        "빌리미의 글",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8C8C8C)),
                      ),
                      const Divider(color: Color(0xFFF4F4F4)),
                      Text(
                        data['description'],
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF565656)),
                      ),
                      const Divider(color: Color(0xFFF4F4F4)),
                      const Text(
                        "위치",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8C8C8C)),
                      ),
                      const SizedBox(height: 10.0),
                      /*
                      SizedBox(
                        height: 300,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                  data['map'].latitude, data['map'].longitude),
                              zoom: 14.4746,
                            ),
                            markers: {
                              Marker(
                                markerId: const MarkerId('map'),
                                position: LatLng(data['map'].latitude,
                                    data['map'].longitude),
                              ),
                            },
                          ),
                        ),
                      ),
                      */
                      const SizedBox(height: 30.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 10.0,
          left: 10.0,
          child: SafeArea(
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              iconSize: 30.0,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
        Positioned(
          bottom: 20.0,
          right: 20.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 120.0,
                child: ElevatedButton(
                  onPressed: () {
                    // "채팅하기" 버튼이 눌렸을 때의 동작을 정의합니다.
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB900),
                    elevation: 5.0,
                  ),
                  child: const Text('채팅하기',
                      style: TextStyle(fontSize: 15, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
