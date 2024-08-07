import 'dart:convert';

import 'package:billimiut_app/screens/post_info_screen.dart';
import 'package:flutter/material.dart';

class TransactionItem extends StatelessWidget {
  final String postId;
  final String imageUrl;
  final String location;
  final String title;
  final int price;
  final String startDate;
  final String endDate;
  final String status;

  const TransactionItem({
    super.key,
    required this.postId,
    required this.imageUrl,
    required this.location,
    required this.title,
    required this.price,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  ImageProvider<Object> loadImage(String? imageUrl) {
    print("imageUrl: $imageUrl");
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(
              docId: postId,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 10.0,
        ),
        color: status == "종료"
            ? Colors.grey.withOpacity(0.3)
            : const Color(0xFFF4F4F4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Image(
                  image: loadImage(
                    imageUrl,
                  ),
                  width: 60,
                  height: 60,
                )
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
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      status,
                      style: const TextStyle(
                        color: Color(0xFFFFB900),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
