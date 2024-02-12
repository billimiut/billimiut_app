import 'package:billimiut_app/providers/user.dart';
import 'package:billimiut_app/widgets/reciever_chatting_box.dart';
import 'package:billimiut_app/widgets/sender_chatting_box.dart';
import 'package:billimiut_app/widgets/transaction_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChattingDetail extends StatefulWidget {
  final String neighborId;
  final String postId;
  const ChattingDetail({
    super.key,
    required this.neighborId,
    required this.postId,
  });

  @override
  State<ChattingDetail> createState() => _ChattingDetailState();
}

class _ChattingDetailState extends State<ChattingDetail> {
  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    print(user.userId);
    print(widget.neighborId);

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
        title: const Text(
          "제주한라봉",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF565656),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: const Column(
          children: [
            TransactionItem(
              imageUrl: "https://via.placeholder.com/80",
              location: "성균관대 제 2공학관",
              title: "저 급하게 생리대가 필요한데 주위에 있으신 분 ...",
              money: 1000,
              startDate: "2/3 11:00",
              endDate: "2/3 11:10",
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                "2024년 1월 23일",
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
              child: Expanded(
                child: Column(
                  children: [
                    SenderChattingBox(
                      text: "안녕하세요!",
                      time: "13:03",
                    ),
                    SizedBox(height: 10),
                    SenderChattingBox(
                      text: "귤 나눔받고싶어서 연락드렸습니다!",
                      time: "13:04",
                    ),
                    SizedBox(height: 10),
                    RecieverChattingBox(
                      text: "네!\n아직 많이 남아있습니다~!\n신관 A동으로 오시면 챗 주세요!",
                      time: "13:20",
                    ),
                  ],
                ),
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
