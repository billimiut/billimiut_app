import 'package:billimiut_app/providers/user.dart';
import 'package:billimiut_app/widgets/profile_card.dart';
import 'package:billimiut_app/widgets/transaction_section.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:billimiut_app/screens/my_posts_screen.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    print("빌린내역 : ${user.borrowList.length}");
    print("빌려준 내역: ${user.lendList.length}");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(
          user.nickname,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF565656),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              size: 24,
            ),
            onPressed: () {
              // 버튼이 눌렸을 때 수행할 동작 작성
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              ProfileCard(
                imageUrl: user.imageUrl,
                nickname: user.nickname,
                temperature: user.temperature,
                location: "",
                borrowCount: user.borrowCount,
                lendCount: user.lendCount,
                borrowMoney: user.borrowMoney,
                lendMoney: user.lendMoney,
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    child: const Row(
                      children: [
                        Text(
                          "빌린 내역",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8C8C8C),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: user.borrowList.asMap().entries.map((entry) {
                      int index = entry.key;
                      var item = entry.value;
                      //print("빌린 item: $item");
                      //print("image_url[0]: ${item["image_url"][0]}");
                      return item != null
                          ? TransactionItem(
                              imageUrl: item["image_url"][0],
                              location: item["name"],
                              title: item["title"],
                              money: item["money"],
                              startDate: formatDate(item["start_date"]),
                              endDate: formatDate(item["end_date"]),
                              status: item["status"],
                            )
                          : Container();
                    }).toList(),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    child: const Row(
                      children: [
                        Text(
                          "빌려준 내역",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF8C8C8C),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: user.lendList.asMap().entries.map((entry) {
                      int index = entry.key;
                      var item = entry.value;
                      //print("빌려준 item: $item");
                      //print("image_url[0]: ${item["image_url"][0]}");
                      return item != null
                          ? TransactionItem(
                              imageUrl: item["image_url"][0],
                              location: item["name"],
                              title: item["title"],
                              money: item["money"],
                              startDate: DateFormat('yy-MM-dd HH:mm')
                                  .format(DateTime.parse(item["start_date"])),
                              endDate: DateFormat('yy-MM-dd HH:mm')
                                  .format(DateTime.parse(item["end_date"])),
                              status: item["status"],
                            )
                          : Container();
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
