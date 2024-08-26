import 'dart:convert';

import 'package:billimiut_app/providers/posts.dart';
import 'package:billimiut_app/providers/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ChattingPostDetail extends StatelessWidget {
  final int index;
  final int index2;
  final Map<String, dynamic>? post;
  final String postId;
  final String imageUrl;
  final String location;
  final String title;
  final int price;
  final String startDate;
  final String endDate;
  final bool borrow;
  final String status;
  final String neighborUuid;
  final String neighborNickname;
  final String item;
  final bool isButtonShowed;

  const ChattingPostDetail({
    super.key,
    required this.index,
    required this.index2,
    required this.post,
    required this.postId,
    required this.imageUrl,
    required this.location,
    required this.title,
    required this.price,
    required this.startDate,
    required this.endDate,
    required this.borrow,
    required this.status,
    required this.neighborUuid,
    required this.neighborNickname,
    required this.item,
    required this.isButtonShowed,
  });
  ImageProvider<Object> loadImage(String? imageUrl) {
    //print(imageUrl);
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

  @override
  Widget build(BuildContext context) {
    print(isButtonShowed);
    User user = Provider.of<User>(context);
    Posts posts = Provider.of<Posts>(context);
    print("status: $status");
    print("index: $index");
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 10.0,
      ),
      color: const Color(0xFFF4F4F4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            children: [
              Image(
                image: loadImage(imageUrl),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ],
          ),
          const SizedBox(
            width: 18,
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF565656),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF565656),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Text(
                        price == 0 ? "나눔" : "$price원",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF565656),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        startDate,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF565656),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      const Text(
                        "~",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF565656),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        endDate,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF565656),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          isButtonShowed
              ? GestureDetector(
                  onTap: () {
                    if (index != -1) {
                      if (status == "게시") {
                        // 빌려주기 -> 빌림중
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            // 모달 내용 구성
                            return AlertDialog(
                              title: const Text(
                                '빌려주기',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF565656),
                                ),
                              ),
                              content: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: neighborNickname,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF565656),
                                      ),
                                    ),
                                    const TextSpan(
                                      text: "님께 ",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF565656),
                                      ),
                                    ),
                                    TextSpan(
                                      text: item,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF565656),
                                      ),
                                    ),
                                    const TextSpan(
                                      text: " 빌려주시겠습니까?",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF565656),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFA0A0A0),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      '취소',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFB900),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: TextButton(
                                    onPressed: () async {
                                      var apiEndPoint =
                                          dotenv.get("API_END_POINT");
                                      var request =
                                          Uri.parse('$apiEndPoint/post/status');
                                      var body = {
                                        "post_id": postId,
                                        "borrower_uuid": neighborUuid,
                                        "lender_uuid": user.uuid,
                                        "status": "빌림중",
                                      };
                                      print("body: $body");
                                      var response = await http
                                          .put(
                                        request,
                                        headers: {
                                          'Content-Type': 'application/json'
                                        },
                                        body: jsonEncode(body),
                                      )
                                          .then((value) {
                                        var data = json.decode(
                                            utf8.decode(value.bodyBytes));
                                        print("post/status data: $data");
                                        if (data["message"] == 1) {
                                          print("게시 -> 빌림중");
                                          // 상태 변경
                                          posts.changeOriginPosts(
                                              index, index2, "status", "빌림중");
                                          user.addLendList(post);
                                          Navigator.of(context).pop();
                                        }
                                      }).catchError((e) {
                                        print("/post/status error: $e");
                                      });
                                    },
                                    child: const Text(
                                      '확인',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF565656),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                      if (status == "빌림중") {
                        // 빌림중 -> 종료
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            // 모달 내용 구성
                            return AlertDialog(
                              title: const Text(
                                '종료하기',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF565656),
                                ),
                              ),
                              content: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: neighborNickname,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF565656),
                                      ),
                                    ),
                                    const TextSpan(
                                      text: "님께 ",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF565656),
                                      ),
                                    ),
                                    TextSpan(
                                      text: item,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF565656),
                                      ),
                                    ),
                                    const TextSpan(
                                      text: " 돌려받았으며, 빌려줌을 종료하겠습니다.",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF565656),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFA0A0A0),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      '취소',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFB900),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: TextButton(
                                    onPressed: () async {
                                      var apiEndPoint =
                                          dotenv.get("API_END_POINT");
                                      var request =
                                          Uri.parse('$apiEndPoint/post/status');
                                      var body = {
                                        "post_id": postId,
                                        "borrower_uuid": neighborUuid,
                                        "lender_uuid": user.uuid,
                                        "status": "종료",
                                      };
                                      print(body);
                                      var response = await http
                                          .put(
                                        request,
                                        headers: {
                                          'Content-Type': 'application/json'
                                        },
                                        body: jsonEncode(body),
                                      )
                                          .then((value) {
                                        var data = json.decode(
                                            utf8.decode(value.bodyBytes));
                                        print("post/status data: $data");
                                        if (data["message"] == 1) {
                                          // 상태 변경
                                          print("빌림중 -> 종료");
                                          posts.changeOriginPosts(
                                              index, index2, "status", "종료");
                                          Navigator.of(context).pop();
                                        }
                                      }).catchError((e) {
                                        print("/post/status error: $e");
                                      });
                                    },
                                    child: const Text(
                                      '확인',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: status == "종료"
                              ? Colors.grey
                              : const Color(0xff007DFF),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Text(
                          status == "게시" ? "빌려주기" : status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
