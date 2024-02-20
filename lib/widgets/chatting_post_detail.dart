import 'dart:convert';

import 'package:billimiut_app/providers/posts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChattingPostDetail extends StatelessWidget {
  final int index;
  final String imageUrl;
  final String location;
  final String title;
  final int money;
  final String startDate;
  final String endDate;
  final String status;

  const ChattingPostDetail(
      {super.key,
      required this.index,
      required this.imageUrl,
      required this.location,
      required this.title,
      required this.money,
      required this.startDate,
      required this.endDate,
      required this.status});
  ImageProvider<Object> loadImage(String? imageUrl) {
    print(imageUrl);
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
    Posts posts = Provider.of<Posts>(context);
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
                        money == 0 ? "나눔" : "$money원",
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
          GestureDetector(
            onTap: () {
              if (index != -1) {
                if (status == "빌려주기") {
                  print("빌려주기에서 빌림중으로 바꾸겠습니까?");
                  posts.changeOriginPosts(index, "status", "빌림중");
                  //posts.originPosts[index]["status"] =
                }
                if (status == "빌림중") {
                  print("빌림중에서 종료로 바꾸겠습니까?");
                  posts.changeOriginPosts(index, "status", "종료");
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
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
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
