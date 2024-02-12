import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:billimiut_app/providers/user.dart';
import 'package:billimiut_app/widgets/reciever_chatting_box.dart';
import 'package:billimiut_app/widgets/sender_chatting_box.dart';
import 'package:billimiut_app/widgets/transaction_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostData {
  final List<String> imageUrl;
  final String location;
  final String title;
  final int money;
  final String startDate;
  final String endDate;

  PostData(this.imageUrl, this.location, this.title, this.money, this.startDate, this.endDate);
}

class ChatRoomScreen extends StatelessWidget {
  final String userId;
  final String postId;
  
  ChatRoomScreen({required this.userId, required this.postId});

  Future<PostData> fetchPostData() async {
    var apiEndPoint = dotenv.get("API_END_POINT");
    var postResponse = await http.get(Uri.parse('$apiEndPoint/get_post?post_id=$postId'));
    var post = json.decode(postResponse.body);

    return PostData(
      post['image_url'].cast<String>(),
      post['location_id'],
      post['title'],
      post['money'],
      post['start_date'],
      post['end_date'],
    );
  }

  Future<List<Widget>> fetchChatData(User user) async {
    var apiEndPoint = dotenv.get("API_END_POINT");
    var chatResponse = await http.get(Uri.parse('$apiEndPoint/get_messages/DpNShk2oNgcFoudzI2uboZv5zXn2JWguSs0WqJcdFWtwzrvYVJdSN8k2'));
    var chat = json.decode(chatResponse.body);

    return chat['messages'].map<Widget>((message) {
      var time = DateTime.parse(message['time']).toLocal().toString().substring(11, 16);

      var text = message['message'];

      var senderId = message['sender_id'];

      print('senderId: $senderId, user.userId: ${user.userId}');
      if (senderId == user.userId) {
        return SenderChattingBox(
          text: text,
          time: time,
        );
      } else {
        return RecieverChattingBox(
          text: text,
          time: time,
        );
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          userId,
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
            FutureBuilder<PostData>(
              future: fetchPostData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return TransactionItem(
                    imageUrl: snapshot.data!.imageUrl[0],
                    location: snapshot.data!.location,
                    title: snapshot.data!.title,
                    money: snapshot.data!.money,
                    startDate: snapshot.data!.startDate,
                    endDate: snapshot.data!.endDate,
                  );
                }
              },
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                "2024년 2월 11일",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF8C8C8C),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: FutureBuilder<List<Widget>>(
                future: fetchChatData(user),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Column(
                      children: snapshot.data!,
                    );
                  }
                },
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
            GestureDetector(
              onTap: () {},
              child: const Icon(
                Icons.notifications_active,
                size: 24.0,
                color: Color(0xFFFFB900),
              ),
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

class TransactionItem extends StatelessWidget {
  final String imageUrl;
  final String location;
  final String title;
  final int money;
  final String startDate;
  final String endDate;

  TransactionItem({
    required this.imageUrl,
    required this.location,
    required this.title,
    required this.money,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              location,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            Text(
              '\$${money.toString()}',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Text(
              'Start: $startDate',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            Text(
              'End: $endDate',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChattingDetail extends StatefulWidget {
  const ChattingDetail({super.key});

  @override
  State<ChattingDetail> createState() => _ChattingDetailState();
}

class _ChattingDetailState extends State<ChattingDetail> {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    print('user.userId: ${user.userId}');
    List<dynamic> chatList = user.chatList;

    List<Map<String, String>> userIdsAndPostIds = chatList
        .map((chatId) {
          var parts = (chatId as String).split('-');
          return {'userId': parts.first, 'postId': parts.last};
        })
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat List'),
      ),
      body: ListView.builder(
        itemCount: userIdsAndPostIds.length,
        itemBuilder: (context, index) {
          String userId = userIdsAndPostIds[index]['userId']!;
          String postId = userIdsAndPostIds[index]['postId']!;
          return ListTile(
            title: Text(userId),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatRoomScreen(userId: userId, postId: postId)),
              );
            },
          );
        },
      ),
    );
  }
}