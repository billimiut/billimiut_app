import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // 날짜 형식을 변경하기 위해 필요
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:billimiut_app/providers/user.dart';
import 'package:billimiut_app/providers/posts.dart';
import 'package:billimiut_app/screens/chatting_detail_screen.dart';
import 'dart:convert';

class DetailPage extends StatelessWidget {
  final String docId; // 클릭한 리스트 아이템의 document id

  String formatDate(DateTime date) {
    return DateFormat('yyyy.MM.dd HH:mm').format(date);
  }

  const DetailPage({super.key, required this.docId});

  ImageProvider<Object> loadImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      Uri dataUri = Uri.parse(imageUrl);
      if (dataUri.scheme == "data") {
        return MemoryImage(base64Decode(dataUri.data!.contentAsString()));
      } else if (dataUri.isAbsolute) {
        return NetworkImage(imageUrl);
      }
    }
    return const AssetImage('assets/profile.png');
  }

  @override
  Widget build(BuildContext context) {
    Posts postsProvider = Provider.of<Posts>(context);
    User user = Provider.of<User>(context);

    Map<String, dynamic>? data = postsProvider.allPosts
        .firstWhere((post) => post['post_id'] == docId, orElse: () => null);

    print("data: $data");

    if (data == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text("해당 게시물이 존재하지 않습니다."),
        ),
      );
    }

    String startDateString = data['start_date'];
    DateTime startDate = DateTime.parse(startDateString);
    String endDateString = data['end_date'];
    DateTime endDate = DateTime.parse(endDateString);

    double latitude = 0.0, longitude = 0.0;
    if (data['map'] != null && data['map'] != null) {
      latitude = data['map']['latitude'];
      longitude = data['map']['longitude'];
    }

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
            child: titleWidget,
          ),
          const SizedBox(width: 10.0),
          const Icon(Icons.notification_important,
              color: Colors.red, size: 30.0),
        ],
      );
    }

    return Scaffold(
      // 추가된 부분: Scaffold로 감싸기
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: (data['image_url'] == null ||
                                data['image_url'].isEmpty)
                            ? [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height / 4,
                                  width: MediaQuery.of(context).size.width,
                                  child: Image.asset(
                                    'assets/no_image.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ]
                            : List<Widget>.from(data['image_url'].map((url) {
                                return SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height / 4,
                                  width: MediaQuery.of(context).size.width,
                                  child: Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }).toList()),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: loadImage(
                                        (data['profile'] != null &&
                                                (data['profile'] as String)
                                                    .isNotEmpty)
                                            ? data['profile'] as String
                                            : null),
                                    radius: 30,
                                  ),
                                  const SizedBox(width: 10.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['nickname'].isNotEmpty
                                            ? "${data['nickname']}님"
                                            : "정보없음",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF565656),
                                        ),
                                      ),
                                      Text(
                                        data['dong'].isNotEmpty
                                            ? data['dong']
                                            : "정보없음",
                                        style: const TextStyle(
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                alignment: Alignment.center,
                                decoration: (data['status'] == '빌림중' ||
                                        data['status'] == '종료')
                                    ? BoxDecoration(
                                        color: data['status'] == "빌림중"
                                            ? Color(0xff007DFF)
                                            : Colors.grey,
                                        borderRadius: BorderRadius.circular(10),
                                      )
                                    : null,
                                child: (data['status'] == '빌림중' ||
                                        data['status'] == '종료')
                                    ? Text(
                                        data[
                                            'status'], // "빌림중", "종료"일 때는 해당 상태를 표시합니다.
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        titleWidget,
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
                                data['name'] != null && data['name'].isNotEmpty
                                    ? data['name'] +
                                        " " +
                                        data['detail_address']
                                    : data['detail_address'],
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
                                data['money'] == 0 ? '나눔' : '${data['money']}원',
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
                                "${formatDate(startDate)} ~ ${formatDate(endDate)}",
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
                        SizedBox(
                          height: 300,
                          child: (longitude != 0 && latitude != 0)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height:
                                        MediaQuery.of(context).size.height / 2,
                                    child: GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                        target: LatLng(
                                          latitude,
                                          longitude,
                                        ),
                                        zoom: 14.4746,
                                      ),
                                      markers: {
                                        Marker(
                                          markerId: const MarkerId('map'),
                                          position: LatLng(
                                            latitude,
                                            longitude,
                                          ),
                                        ),
                                      },
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: Text(
                                      '위치정보가 준비중입니다...')), // 지도 정보가 없는 경우에는 이 메시지를 표시합니다.
                        ),
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
                  width: 120,
                  child: ElevatedButton(
                    onPressed: data['status'] != '종료' &&
                            data['writer_id'] != user.userId
                        ? () {
                            // "채팅하기" 버튼이 눌렸을 때의 동작을 정의합니다.
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChattingDetail(
                                  // 'post'는 현재 글 객체를 의미합니다. 적절한 변수명으로 변경해주세요.
                                  // 'post.author'는 글의 작성자를 의미합니다. 적절한 변수명으로 변경해주세요.
                                  postId: data['post_id'],
                                  neighborId: data['writer_id'],
                                  neighborNickname: data['nickname'],
                                ),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB900),
                      elevation: 5.0,
                    ),
                    child: const Text('채팅하기',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
