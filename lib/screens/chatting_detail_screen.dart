import 'dart:convert';

import 'package:billimiut_app/providers/posts.dart';
import 'package:billimiut_app/providers/user.dart';
import 'package:billimiut_app/widgets/chatting_post_detail.dart';
import 'package:billimiut_app/widgets/reciever_chatting_box.dart';
import 'package:billimiut_app/widgets/sender_chatting_box.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ChattingDetail extends StatefulWidget {
  final String neighborNickname;
  final String neighborId;
  final String postId;

  const ChattingDetail({
    super.key,
    required this.neighborNickname,
    required this.neighborId,
    required this.postId,
  });

  @override
  State<ChattingDetail> createState() => _ChattingDetailState();
}

class _ChattingDetailState extends State<ChattingDetail> {
  var messages = [];

  @override
  void initState() {
    super.initState();
    getMessages();
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
        return '';
      }
      return DateFormat('MM/dd HH:mm').format(date);
    } else {
      return '';
    }
  }

  Future<void> getMessages() async {
    User user = Provider.of<User>(context, listen: false);
    List<String> sortedIds = [user.userId, widget.neighborId]..sort();
    String getMessagesId = sortedIds.join();
    var apiEndPoint = dotenv.get("API_END_POINT");
    var getMessagesRequest =
        Uri.parse('$apiEndPoint/get_messages/$getMessagesId');

    var getMessagesresponse = await http.get(
      getMessagesRequest,
      headers: {'Content-Type': 'application/json'},
    ).then((value) {
      var getMessagesData = jsonDecode(value.body);
      getMessagesData = json.decode(utf8.decode(value.bodyBytes));
      setState(() {
        messages = getMessagesData["messages"];
      });
      //print(messages);
      //print(getMessagesData["messages"].length);
    }).catchError((e) {
      print("/get_messages error: $e");
    });
  }

  @override
  Widget build(BuildContext context) {
    Posts posts = Provider.of<Posts>(context);
    User user = Provider.of<User>(context);

    Map<String, dynamic>? post = posts.allPosts.firstWhere(
        (post) => post['post_id'] == widget.postId,
        orElse: () => null);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // < 버튼이 눌렸을 때 수행할 작업 작성
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.neighborNickname,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF565656),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          children: [
            ChattingPostDetail(
              imageUrl: post!["image_url"][0] ?? "",
              location: loadLocation(post["name"]),
              title: post["title"] ?? "",
              money: post["money"],
              startDate: formatDate(post["start_date"]),
              endDate: formatDate(post["end_date"]),
              status: post["status"] == "게시" ? "빌려주기" : post["status"],
            ),
            const SizedBox(
              height: 20,
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: Column(
                  children: messages.asMap().entries.map((entry) {
                    int index = entry.key;
                    var value = entry.value;
                    bool isPostMessage = widget.postId == value["post_id"];
                    //print(isPostMessage);
                    bool isUserMessage = user.userId == value["sender_id"];
                    if (isPostMessage && isUserMessage) {
                      return Container(
                        child: Column(children: [
                          SenderChattingBox(
                            text: value["message"],
                            time: formatDate(value["time"]),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                        ]),
                      );
                    } else if (isPostMessage && !isUserMessage) {
                      return Container(
                        child: Column(children: [
                          RecieverChattingBox(
                            text: value["message"],
                            time: formatDate(value["time"]),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                        ]),
                      );
                    } else {
                      // Do nothing if neither condition is met
                      return Container();
                    }
                  }).toList(),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              decoration: const BoxDecoration(
                  color: Color(
                0xFFF4F4F4,
              )),
              child: Row(
                children: [
                  Container(
                    color: Colors.white,
                    child: const Icon(
                      Icons.add,
                      size: 24.0,
                      color: Color(0xFFA0A0A0),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      child: const TextField(
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                          hintText: '메세지를 입력하세요.',
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                        maxLength: 1000,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xff007DFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "전송",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF4F4F4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
