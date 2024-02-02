import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // 날짜 형식을 변경하기 위해 필요
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
    CollectionReference posts = FirebaseFirestore.instance.collection('posts');
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: posts.doc(docId).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("오류가 발생했습니다: ${snapshot.error}");
          }
          if (snapshot.hasData && !snapshot.data!.exists) {
            return const Text("해당 게시물이 존재하지 않습니다.");
          }
          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            DateTime startDate = data['startDate'].toDate();
            DateTime endDate = data['endDate'].toDate();
            return Stack(
              children: [
                SingleChildScrollView(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 50.0), // 이미지 위에 Padding 추가
                          child: Image.network(
                            data['imageUrl'],
                            height: MediaQuery.of(context).size.height /
                                4, // 이미지 높이를 페이지의 1/4로 설정
                            width: MediaQuery.of(context)
                                .size
                                .width, // 이미지 너비를 페이지 너비와 동일하게 설정
                            fit: BoxFit.cover, // 이미지를 꽉 차게 늘림
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        'https://url.kr/t5lipd'), // 사용자 프로필 이미지
                                    radius: 30, // 프로필 사진의 반지름
                                  ),
                                  SizedBox(width: 10.0), // 프로필 사진과 이름 사이의 간격
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "육성재님", //data['userName'], // 작성자 이름
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF565656)),
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
                              const SizedBox(height: 20.0),
                              Text(data['title'],
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF565656))), // 제목
                              const SizedBox(height: 10.0),
                              const Text("상세정보",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF8C8C8C))),
                              const Divider(
                                color: Color(0xFFF4F4F4), // 색상 코드 지정
                              ),
                              Row(
                                children: [
                                  const Expanded(
                                    flex: 1,
                                    child: Text('장소:',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF565656))),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(data['location'],
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF565656))),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Expanded(
                                    flex: 1,
                                    child: Text('빌림품목:',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF565656))),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(data['item'],
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF565656))),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Expanded(
                                    flex: 1,
                                    child: Text('가격:',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF565656))),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text('${data['money']}원',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF565656))),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Expanded(
                                    flex: 1,
                                    child: Text('빌림시간:',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF565656))),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      "${DateFormat('yyyy.MM.dd HH:mm').format(startDate)} ~ ${DateFormat('yyyy.MM.dd HH:mm').format(endDate)}",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF565656)),
                                    ),
                                  ),
                                ],
                              ),

                              const Divider(
                                color: Color(0xFFF4F4F4), // 색상 코드 지정
                              ),
                              const Text("빌리미의 글",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF8C8C8C))),
                              const Divider(
                                color: Color(0xFFF4F4F4), // 색상 코드 지정
                              ),
                              Text(data['description'],
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF565656))), // 상세 설명
                              const Divider(
                                color: Color(0xFFF4F4F4), // 색상 코드 지정
                              ),
                              const Text("위치",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF8C8C8C))), // 위치
                              const SizedBox(height: 10.0),
                              SizedBox(
                                height: 300,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      20), // 모서리 둥근 정도를 조절합니다.
                                  child: GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: LatLng(data['map'].latitude,
                                          data['map'].longitude),
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: Positioned(
                    top: 10.0,
                    left: 10.0,
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
                  bottom: 15.0, // 버튼을 화면 하단에 위치시킵니다.
                  left: 20.0, // 버튼을 화면 좌측으로부터 20 만큼 떨어지게 합니다.
                  right: 20.0, // 버튼을 화면 우측으로부터 20 만큼 떨어지게 합니다.
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ElevatedButton(
                          onPressed: () {
                            // "채팅하기" 버튼이 눌렸을 때의 동작을 정의합니다.
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                                0xFF007DFF), // 버튼의 배경색을 파란색으로 설정합니다.
                            elevation: 5.0,
                          ),
                          child: const Text('채팅하기',
                              style: TextStyle(
                                  fontSize: 15,
                                  //fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 10.0), // 버튼 사이의 간격
                      Expanded(
                        flex: 6,
                        child: ElevatedButton(
                          onPressed: () {
                            // "빌려주기" 또는 "빌리기" 버튼이 눌렸을 때의 동작을 정의합니다.
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                                0xFFFFB900), // 버튼의 배경색을 노란색으로 설정합니다.
                            elevation: 5.0,
                          ),
                          child: Text(data['borrow'] ? '빌려주기' : '빌리기',
                              style: const TextStyle(
                                  fontSize: 15,
                                  //fontWeight: FontWeight.bold,
                                  color: Colors
                                      .white)), // borrow 값에 따라 버튼의 텍스트를 변경합니다.
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const CircularProgressIndicator(); // 데이터를 로드하는 동안 보여질 위젯
        },
      ),
    );
  }
}
