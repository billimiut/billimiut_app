import 'package:billimiut_app/providers/user.dart';
import 'package:billimiut_app/widgets/profile_card.dart';
import 'package:billimiut_app/widgets/transaction_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // < 버튼이 눌렸을 때 수행할 작업 작성
          },
        ),
        title: Text(
          user.nickname,
          style: const TextStyle(
            fontSize: 15,
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
      body: Container(
        child: Column(
          children: [
            ProfileCard(
              imageUrl: "https://via.placeholder.com/60",
              nickname: user.nickname,
              temperature: user.temperature,
              location: user.location[0],
              borrowCount: user.borrowCount,
              lendCount: user.lendCount,
              totalMoney: user.totalMoney,
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
                const TransactionItem(
                  imageUrl: "https://via.placeholder.com/80",
                  location: "성균관대 제 2공학관",
                  title: "저 급하게 생리대가 필요한데 주위에 있으신 분 ...",
                  money: 1000,
                  startDate: "2/3 11:00",
                  endDate: "2/3 11:10",
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
                const TransactionItem(
                  imageUrl: "https://via.placeholder.com/80",
                  location: "성균관대 제 2공학관",
                  title: "저 급하게 생리대가 필요한데 주위에 있으신 분 ...",
                  money: 1000,
                  startDate: "2/3 11:00",
                  endDate: "2/3 11:10",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
