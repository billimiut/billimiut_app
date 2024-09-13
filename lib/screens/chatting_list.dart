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
    if (diff.isNegative || diff.inMinutes < 1) {
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
    setState(() {
      user.chatList.sort((a, b) => DateTime.parse(b['last_message_time'])
          .compareTo(DateTime.parse(a['last_message_time'])));
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "채팅",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF565656),
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.notifications,
              size: 24,
            ),
            onPressed: () {
              // 알림 버튼이 눌렸을 때의 동작을 구현하세요.
            },
          ),
        ],
      ),
      body: user.chatList.isEmpty
          ? const Center(
              child: Text(
                "채팅 기록이 없습니다.\n이웃과 채팅을 시작해보세요!",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: user.chatList.length,
              itemBuilder: (context, index) {
                var chat = user.chatList[index];
                print(chat);
                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: loadImage((chat['neighbor_profile'] !=
                                    null &&
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
                      trailing: Text(getTimeAgo(
                          DateTime.parse(chat['last_message_time']))),
                      onTap: () {
                        // ListTile이 눌렸을 때의 동작을 정의합니다.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChattingDetail(
                              postId: chat['post_id'] ?? 'unknown', // 기본값 제공
                              neighborUuid:
                                  chat['neighbor_id'] ?? 'unknown', // 기본값 제공
                              neighborNickname: chat['neighbor_nickname'] ??
                                  'unknown', // 기본값 제공
                              postStatus:
                                  chat['post_status'] ?? 'unknown', // 기본값 제공
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
