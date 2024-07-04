import 'dart:async';
import 'dart:convert';

import 'package:billimiut_app/models/post.dart';
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
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

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
  var apiEndPoint = dotenv.get("API_END_POINT");
  var webSocketEndPoint = dotenv.get("WEB_SOCKET_END_POINT");
  late User user;
  late final WebSocketChannel channel; // 웹소켓
  var messages = [];

  StreamController<Map<String, dynamic>> messagesController =
      StreamController<Map<String, dynamic>>();
  final TextEditingController messageController = TextEditingController();
  var query = "";
  var index = -1;

  @override
  void initState() {
    super.initState();
    User user = Provider.of<User>(context, listen: false);
    Posts posts = Provider.of<Posts>(context, listen: false);
    print('userId: ${user.id}');
    print('neigborId: ${widget.neighborId}');
    print('postId: ${widget.postId}');

    setState(() {
      index = posts.originPosts
          .indexWhere((post) => post["post_id"] == widget.postId);
    });
    print('index: $index');
    //channel = IOWebSocketChannel.connect('ws://10.0.2.2:8000/ws/${user.userId}'); // 웹소켓
    getMessages();
    channel =
        IOWebSocketChannel.connect(Uri.parse('$webSocketEndPoint/${user.id}'));
    channel.stream.listen((event) {
      var jsonData = json.decode(event);
      print("jsonData: $jsonData");
      messagesController.add({
        "post_id": jsonData["post_id"],
        "sender_id": jsonData["sender_id"],
        "message": jsonData["message"],
        "time": jsonData["time"],
      });
    });
  }

  // 웹소켓
  @override
  void dispose() {
    messageController.dispose();
    //messagesController.close();
    channel.sink.close();
    super.dispose();
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

  void addMessages(dynamic message) {
    setState(() {
      messages.add(message);
    });
  }

  // 웹소켓
  Future<void> sendMessage() async {
    final user = Provider.of<User>(context, listen: false);

    if (messageController.text.isNotEmpty) {
      final message = {
        'message': messageController.text,
        'sender_id': user.id,
        'receiver_id': widget.neighborId,
        'post_id': widget.postId,
      };

      channel.sink.add(json.encode(message));
      setState(() {
        messagesController.add({
          'post_id': widget.postId,
          'sender_id': user.id,
          'message': messageController.text,
          'time': DateTime.now().toLocal().toIso8601String(),
        });
        messageController.text = "";
        messageController.clear();
        //messagesController.add(message);
      });

      print("messages.length: ${messages.length}");
    }
  }

  Future<void> getMessages() async {
    User user = Provider.of<User>(context, listen: false);

    List<String> sortedIds = [user.id, widget.neighborId]..sort();
    String getMessagesId = sortedIds.join();

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
        //messagesController = getMessagesData["messages"];
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
              index: index,
              postId: widget.postId,
              imageUrl:
                  post!["image_url"] != null && post["image_url"].isNotEmpty
                      ? post["image_url"][0]
                      : "",
              location: loadLocation(post["name"]),
              title: post["title"] ?? "",
              price: post["price"],
              startDate: formatDate(post["start_date"]),
              endDate: formatDate(post["end_date"]),
              borrow: post["borrow"],
              status: post["status"] == "게시" ? "빌려주기" : post["status"],
              neighborId: widget.neighborId,
              neighborNickname: widget.neighborNickname,
              item: post["item"] ?? "",
              isButtonShowed: (post["borrow"] == false &&
                      post["writer_uuid"] == user.uuid) ||
                  (post["borrow"] == true && post["writer_uuid"] != user.uuid),
            ),
            const SizedBox(
              height: 20,
            ),
            const SizedBox(
              height: 20,
            ),

            // 웹소켓 (메시지 받기)
            StreamBuilder(
              stream: messagesController.stream,
              builder: (context, snapshot) {
                Map<String, dynamic>? data;
                if (snapshot.hasData) {
                  data = snapshot.data;
                  print(data);
                  messages.add({
                    "post_id": data!["post_id"],
                    "sender_id": data["sender_id"],
                    "message": data["message"],
                    "time": data["time"],
                  });
                  // messagesController.add({
                  // "postId": widget.postId,
                  // "sender_id": widget.neighborId,
                  // "message": jsonData["message"],
                  // "time": jsonData["time"],
                  // });
                }

                List reversedMessages = List.from(messages.reversed);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: ListView.builder(
                      reverse: true,
                      itemCount: reversedMessages.length,
                      itemBuilder: (context, index) {
                        var value = reversedMessages[index];
                        bool isPostMessage = widget.postId == value["post_id"];
                        bool isUserMessage = user.id == value["sender_id"];
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
                      },
                    ),
                  ),
                );
              },
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
                      child: TextField(
                        controller: messageController,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
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
                    onTap: () {
                      // 웹소켓 (메시지 보내기)
                      //print(messageController.text);
                      sendMessage();
                    },
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
