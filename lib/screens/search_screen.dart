import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:billimiut_app/providers/posts.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:billimiut_app/screens/post_info_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("검색"),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              decoration: const InputDecoration(
                labelText: "검색어를 입력하세요",
              ),
            ),
          ),
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    List<dynamic> filteredPostsList =
        Provider.of<Posts>(context, listen: false).filteredPosts(_searchText);

    // 데이터가 없는 경우
    if (filteredPostsList.isEmpty) {
      return const Center(child: Text('No data'));
    }

    return ListView.builder(
      itemCount: filteredPostsList.length,
      itemBuilder: (context, index) {
        var post = filteredPostsList[index];
        bool isCompleted = post['status'] == '종료';
        var addressLengthLimit = 25; // 길이 제한을 원하는 값으로 설정하세요.
        var nameAndAddress = post['detail_address']; // 카카오맵으로 바꾸면 변경
        // post['name'] != null && post['name'].isNotEmpty
        //     ? post['name'] + " " + post['detail_address']
        //     : post['detail_address'];
        var address = nameAndAddress.length <= addressLengthLimit
            ? nameAndAddress
            : post['detail_address'];

        var moneyLengthLimit = 5; // 길이 제한을 원하는 값으로 설정하세요.
        var money = post['money'] == 0 ? '나눔' : '${post['money']}';

        if (money != '나눔' && money.length > moneyLengthLimit) {
          money = '${money.substring(0, moneyLengthLimit)}+';
        }
        var dateRange =
            '${formatDate(post['start_date'])} ~ ${formatDate(post['end_date'])}';
        var finalString = "${money.padRight(11)} $dateRange";

        return Stack(
          children: [
            Column(
              children: <Widget>[
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(
                          docId: post['post_id'],
                        ),
                      ),
                    );
                  },
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    loadLocation(address),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11.0,
                                      color: Color(0xFF8c8c8c),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                  onTap: () {
                    // 종료된 게시물이어도 블러처리되어 있지만 상세 페이지로 이동할 수 있어야 합니다.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(
                          docId: post['post_id'],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    color: Colors.grey.withOpacity(0.3),
                  ),
                ),
              ),
          ],
        );
      },
    );
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
