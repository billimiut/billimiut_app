import 'dart:convert';

import 'package:billimiut_app/providers/user.dart';
import 'package:billimiut_app/widgets/chatting_post_detail.dart';
import 'package:billimiut_app/widgets/reciever_chatting_box.dart';
import 'package:billimiut_app/widgets/sender_chatting_box.dart';
import 'package:billimiut_app/widgets/transaction_section.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ChattingDetail extends StatefulWidget {
  final String neighborId;
  final String postId;

  const ChattingDetail({
    super.key,
    required this.neighborId,
    required this.postId,
  });

  @override
  State<ChattingDetail> createState() => _ChattingDetailState();
}

class _ChattingDetailState extends State<ChattingDetail> {
  var messages = [];

  var imageUrl = "";
  var location = "";
  var title = "";
  int money = 0;
  String startDate = "";
  String endDate = "";

  @override
  void initState() {
    super.initState();
    getPost();
    getMessages();
  }

  Future<void> getPost() async {
    print("postId: ${widget.postId}");
    var apiEndPoint = dotenv.get("API_END_POINT");
    var getPostRequest =
        Uri.parse('$apiEndPoint/get_post?post_id=${widget.postId}');
    var getPostResponse = await http.get(
      getPostRequest,
      headers: {'Content-Type': 'application/json'},
    ).then((value) {
      var getPostData = jsonDecode(value.body);
      getPostData = json.decode(utf8.decode(value.bodyBytes));
      setState(() {
        imageUrl = getPostData["image_url"][0];
        title = getPostData["title"];
        money = getPostData["money"];
      });
    }).catchError((error) {
      print('/get_post: $error');
    });
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

    // Handle the response data as needed
    // You can parse the response, update the 'messages' state, and use it in your UI
    // For example:
    // List<Message> parsedMessages = parseMessages(getMessagesresponse.body);
    // setState(() {
    //   messages = parsedMessages;
    // });
  }

  @override
  Widget build(BuildContext context) {
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
        return DateFormat('HH:mm').format(date);
      } else {
        return '';
      }
    }

    User user = Provider.of<User>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // < 버튼이 눌렸을 때 수행할 작업 작성
            //Navigator.pop(context);
          },
        ),
        title: const Text(
          "제주한라봉",
          style: TextStyle(
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
            const ChattingPostDetail(
              imageUrl: "https://via.placeholder.com/80",
              location: "성균관대 제 2공학관",
              title: "저 급하게 생리대가 필요한데 주위에 있으신 분 ...",
              money: 1000,
              startDate: "2/3 11:00",
              endDate: "2/3 11:10",
            ),
            const SizedBox(
              height: 20,
            ),
            const Center(
              child: Text(
                "2024년 1월 23일",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF8C8C8C),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
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
          ],
        ),
      ),
      bottomNavigationBar: Container(
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
            ElevatedButton(
              onPressed: () {},
              child: const Text("전송"),
            ),
          ],
        ),
      ),
    );
  }
}
