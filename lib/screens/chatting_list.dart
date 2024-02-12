import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:billimiut_app/providers/user.dart';
import 'package:billimiut_app/screens/chatting_detail_screen.dart';
import 'dart:convert';

class ChattingList extends StatefulWidget {
  const ChattingList({super.key});

  @override
  State<ChattingList> createState() => _ChattingListState();
}

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

class _ChattingListState extends State<ChattingList> {
  String getTimeAgo(DateTime lastMessageTime) {
    var diff = DateTime.now().difference(lastMessageTime);
    if (diff.isNegative) {
      return '방금 전';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
    } else {
      return '${diff.inDays}일 전';
    }
  }

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
    User user = Provider.of<User>(context);
    user.chatList.sort((a, b) => DateTime.parse(b['last_message_time'])
        .compareTo(DateTime.parse(a['last_message_time'])));

    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // 알림 버튼이 눌렸을 때의 동작을 구현하세요.
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: user.chatList.length,
        itemBuilder: (context, index) {
          var chat = user.chatList[index];
          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: loadImage(
                      (chat['neighbor_profile'] != null &&
                              (chat['neighbor_profile'] as String).isNotEmpty)
                          ? chat['neighbor_profile'] as String
                          : null),
                  radius: 30,
                ),
                title: Text(chat['neighbor_nickname']),
                subtitle: Text(
                  chat['last_message'].length > 20
                      ? '${chat['last_message'].substring(0, 20)}...'
                      : chat['last_message'],
                ),
                trailing:
                    Text(getTimeAgo(DateTime.parse(chat['last_message_time']))),
                onTap: () {
                  // ListTile이 눌렸을 때의 동작을 정의합니다.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChattingDetail(
                        postId: chat['post_id'],
                        neighborId: chat['neighbor_id'],
                      ),
                    ),
                  );
                },
              ),
              const Divider(
                color: Color(0xFFF4F4F4),
                height: 1.0,
              ),
            ],
          );
        },
      ),
    );
  }
}
