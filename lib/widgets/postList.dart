import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class PostList extends StatelessWidget {
  final Map<String, dynamic> post;
  final Function onTap;

  const PostList({super.key, required this.post, required this.onTap});

  ImageProvider<Object> loadImage(String? imageUrl) {
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
        return '날짜정보 없음';
      }
      return DateFormat('MM/dd HH:mm').format(date);
    } else {
      return '날짜정보 없음';
    }
  }

  String remainingTime(dynamic endDate) {
    // String 타입일 경우 DateTime으로 변환
    if (endDate is String) {
      // ISO 8601 형식의 문자열을 DateTime으로 변환
      endDate = DateTime.parse(endDate);
    }
    print("endDate = $endDate");

    final now = DateTime.now();
    print("now = $now");
    final difference = endDate.difference(now);
    print(difference);

    if (difference.isNegative) {
      return '기한종료';
    }

    if (difference.inDays > 0) {
      return '종료까지 남은 시간: ${difference.inDays}일';
    } else if (difference.inHours > 0) {
      return '종료까지 남은 시간: ${difference.inHours}시간';
    } else {
      return '종료까지 남은 시간: ${difference.inMinutes}분';
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isCompleted = post['status'] == '종료';
    var addressLengthLimit = 25;
    var nameAndAddress = post['detail_address'];
    var address = nameAndAddress.length <= addressLengthLimit
        ? nameAndAddress
        : post['detail_address'];

    var priceLengthLimit = 5;
    var price = post['price'] == 0 ? '나눔' : '${post['price']}원';
    if (price != '나눔' && price.length > priceLengthLimit) {
      price = '${price.substring(0, priceLengthLimit)}+';
    }

    var dateRange =
        '${formatDate(post['start_date'])} ~ ${formatDate(post['end_date'])}';
    var endDate = post['end_date'];
    var remainTime = remainingTime(endDate);
    var finalString = "${price.padRight(11)} $remainTime";

    return Stack(
      children: [
        Column(
          children: <Widget>[
            ListTile(
              onTap: () => onTap(),
              title: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFF4F4F4),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Image(
                          image: loadImage(post['image_url'].isNotEmpty
                              ? post['image_url'][0]
                              : null),
                          width: 73,
                          height: 73,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  post['map']
                                      ? "${loadLocation(address)} (${post['distance']}m)"
                                      : loadLocation(address),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 11.0,
                                    color: Color(0xFF8c8c8c),
                                  ),
                                ),
                              ),
                              if (post['emergency'] == true)
                                const Icon(
                                  Icons.notification_important,
                                  color: Colors.red,
                                  size: 20.0,
                                ),
                            ],
                          ),
                          const SizedBox(height: 2.0),
                          Padding(
                            padding: const EdgeInsets.only(right: 24.0),
                            child: Text(
                              post['title'],
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15.0,
                                color: Color(0xFF565656),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                finalString,
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.red,
                                ),
                              ),
                              if (post['female'] == true)
                                const Padding(
                                  padding: EdgeInsets.only(right: 4.0),
                                  child: FaIcon(
                                    FontAwesomeIcons.personDress,
                                    color: Colors.pink,
                                    size: 20.0,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(
              color: Color(0xFFF4F4F4),
              height: 1.0,
            ),
          ],
        ),
        if (isCompleted)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => onTap(),
              child: Container(
                color: Colors.grey.withOpacity(0.3),
              ),
            ),
          ),
      ],
    );
  }
}
