import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 형식을 변경하기 위해 필요
import 'package:provider/provider.dart';
import 'package:billimiut_app/providers/user.dart';
import 'package:billimiut_app/providers/posts.dart';
import 'package:billimiut_app/screens/chatting_detail_screen.dart';
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/post.dart';

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

  Future<void> _showReportDialog(
      String? reporterUuid, BuildContext context) async {
    if (reporterUuid == null || reporterUuid.isEmpty) {
      // reporterUuid가 null이거나 비어있는 경우 에러 처리
      _showAlert(context, '로그인이 필요합니다.');
      return;
    }
    final TextEditingController reportReasonController =
        TextEditingController();
    String? selectedReason;
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFD9D9D9),
              title: const Text(
                '게시물 신고하기',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF565656),
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RadioListTile<String>(
                    title: const Text('부적절한 컨텐츠 포함'),
                    value: '부적절한 컨텐츠 포함',
                    groupValue: selectedReason,
                    contentPadding: const EdgeInsets.only(left: 0.0),
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value;
                        reportReasonController.clear();
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('사기글이 의심됨'),
                    value: '사기글이 의심됨',
                    groupValue: selectedReason,
                    contentPadding: const EdgeInsets.only(left: 0.0),
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value;
                        reportReasonController.clear();
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('기타'),
                    value: '기타',
                    groupValue: selectedReason,
                    contentPadding: const EdgeInsets.only(left: 0.0),
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value;
                      });
                    },
                  ),
                  if (selectedReason == '기타')
                    TextField(
                      controller: reportReasonController,
                      decoration: const InputDecoration(
                        hintText: '신고 사유를 입력하세요',
                      ),
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('취소'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('신고'),
                  onPressed: () async {
                    String reportReason = selectedReason == '기타'
                        ? reportReasonController.text
                        : selectedReason ?? '';

                    if (reportReason.isEmpty) {
                      _showAlert(context, '신고 사유를 선택 또는 입력하세요.');
                      return;
                    }

                    // 서버로 데이터 전송
                    final response =
                        await _sendReport(reporterUuid, reportReason);

                    // 서버 응답에 따라 알림 표시
                    Navigator.of(context).pop(); // 다이얼로그 닫기

                    if (response == 'already reported') {
                      _showAlert(context, '이미 신고한 게시물입니다.');
                    } else if (response == 'post deleted' ||
                        response == 'report added') {
                      _showAlert(context, '신고가 접수되었습니다.');
                    } else {
                      _showAlert(context, '신고에 실패했습니다.');
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<String> _sendReport(String? reporterUuid, String reportReason) async {
    var apiEndPoint = dotenv.get("API_END_POINT");
    var reportUrl = Uri.parse('$apiEndPoint/post/report/$docId');
    var bodyData = jsonEncode(<String, String>{
      'reporter_uuid': reporterUuid ?? '', // null일 경우 빈 문자열로 처리
      'report_reason': reportReason,
    });
    print("body: $bodyData");
    try {
      final response = await http.post(
        reportUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: bodyData,
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print("서버 응답: $responseBody"); // 로그 추가
        return responseBody['message'];
      } else {
        print("서버 오류 상태 코드: ${response.statusCode}"); // 로그 추가
        return 'error';
      }
    } catch (e) {
      print("서버 요청 중 예외 발생: $e"); // 로그 추가
      return 'error';
    }
  }

  void _showAlert(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        // 다이얼로그가 열린 상태에서 1초 후에 자동으로 닫히도록 설정
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context).pop(true);
        });

        return AlertDialog(
          backgroundColor: const Color(0xFFD9D9D9),
          title: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF565656),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Posts postsProvider = Provider.of<Posts>(context);
    User user = Provider.of<User>(context);
    final kakaoJsApiKey = dotenv.get("KAKAO_JS_KEY");

    Map<String, dynamic>? data = postsProvider.allPosts
        .firstWhere((post) => post['post_id'] == docId, orElse: () => null);

    print("data.writer_uuid: $data[writer_uuid]");
    print("user.uuid: ${user.uuid}");

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

    List<dynamic> report = data['report'] ?? [];
    print(report); // 리스트 내용 출력
    print('Number of elements in report: ${report.length}');

    bool map = data['map'];
    double latitude = 0.0, longitude = 0.0;
    if (data['map_coordinate'] != null && data['map_coordinate'] != null) {
      latitude = data['map_coordinate']['latitude'];
      longitude = data['map_coordinate']['longitude'];
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
                                        (data['profile_image'] != null &&
                                                (data['profile_image']
                                                        as String)
                                                    .isNotEmpty)
                                            ? data['profile_image'] as String
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
                                            ? const Color(0xff007DFF)
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
                        Column(
                          children: [
                            if (report.isNotEmpty)
                              const Text(
                                "※신고이력이 있는 게시물입니다. 주의해주세요!",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.red,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 11.0),
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
                                data['detail_address'],
                                // data['name'] != null && data['name'].isNotEmpty
                                //     ? data['name'] +
                                //         " " +
                                //         data['detail_address']
                                //     : data['detail_address'],
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
                                data['price'] == 0 ? '나눔' : '${data['price']}원',
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
                        Text(
                          map ? "위치" : "",
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8C8C8C)),
                        ),
                        const SizedBox(height: 10.0),
                        SizedBox(
                          height: 300,
                          child: (map)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height:
                                        MediaQuery.of(context).size.height / 2,
                                    child: WebView(
                                      initialUrl: '',
                                      onWebViewCreated: (WebViewController
                                          webViewController) {
                                        webViewController
                                            .loadUrl(Uri.dataFromString(
                                          '''
                                            <!DOCTYPE html>
                                            <html>

                                            <head>
                                                <meta charset="utf-8" />
                                                <title>Kakao 지도 시작하기</title>
                                                <style>
                                                  html, body {
                                                      height: 100%;
                                                      margin: 0;
                                                      padding: 0;
                                                  }
                                                  #map {
                                                      width: 100%;
                                                      height: 100%;
                                                  }
                                              </style>
                                            </head>

                                            <body>
                                                <div id="map" style="width:100%;height:100%;"></div>
                                                <script type="text/javascript"
                                                    src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=$kakaoJsApiKey"></script>
                                                <script>
                                                    var container = document.getElementById('map');
                                                    var options = {
                                                        center: new kakao.maps.LatLng($latitude, $longitude),
                                                        level: 2
                                                    };
                                                    var map = new kakao.maps.Map(container, options);

                                                    var marker = new kakao.maps.Marker({
                                                        position: new kakao.maps.LatLng($latitude, $longitude),
                                                        draggable: true
                                                    });
                                                    marker.setMap(map);

                                                    // 지도 클릭 이벤트를 추가하여 마커를 클릭한 위치로 이동시키기
                                                    kakao.maps.event.addListener(map, 'click', function(mouseEvent) {
                                                        var latlng = mouseEvent.latLng; // 클릭한 위치의 좌표
                                                        map.setCenter(latlng); // 지도 중심을 클릭한 위치로 설정
                                                    });
                                                </script>
                                            </body>
                                            </html>
                                            ''',
                                          mimeType: 'text/html',
                                          encoding: Encoding.getByName('utf-8'),
                                        ).toString());
                                      },
                                      javascriptMode:
                                          JavascriptMode.unrestricted,
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: Text(
                                      '위치정보가 준비중입니다...')), // 지도 정보가 없는 경우에는 이 메시지를 표시합니다.
                        ),
                        const SizedBox(height: 30.0),
                        GestureDetector(
                          onTap: () => _showReportDialog(user.uuid, context),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.report, // 신고 아이콘
                                color: Color(0xFF8C8C8C), // 아이콘 색상
                                size: 20.0, // 아이콘 크기
                              ),
                              SizedBox(width: 4.0), // 아이콘과 텍스트 사이의 간격
                              Text(
                                "게시물 신고",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8C8C8C),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30.0),
                        GestureDetector(
                          onTap: () => _showReportDialog(user.uuid, context),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.report, // 신고 아이콘
                                color: Color(0xFF8C8C8C), // 아이콘 색상
                                size: 20.0, // 아이콘 크기
                              ),
                              SizedBox(width: 4.0), // 아이콘과 텍스트 사이의 간격
                              Text(
                                "게시물 신고",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8C8C8C),
                                ),
                              ),
                            ],
                          ),
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
                            data['writer_uuid'] != user.uuid
                        ? () {
                            // "채팅하기" 버튼이 눌렸을 때의 동작을 정의합니다.
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChattingDetail(
                                  // 'post'는 현재 글 객체를 의미합니다. 적절한 변수명으로 변경해주세요.
                                  // 'post.author'는 글의 작성자를 의미합니다. 적절한 변수명으로 변경해주세요.
                                  postId: data['post_id'],
                                  neighborUuid: data['writer_uuid'],
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
