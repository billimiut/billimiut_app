import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String imageUrl;
  final String nickname;
  final double temperature;
  final String location;
  final int borrowNum;
  final int lendNum;
  final int profit;

  const ProfileCard(
      {super.key,
      required this.imageUrl,
      required this.nickname,
      required this.temperature,
      required this.location,
      required this.borrowNum,
      required this.lendNum,
      required this.profit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 10.0,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    child: ClipOval(
                      child: Image.network(
                        imageUrl, // 예시 대체 이미지 URL
                        fit: BoxFit.cover,
                        width: 60,
                        height: 60,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    nickname,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF565656),
                    ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text(
                        "나의 온도",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF565656),
                        ),
                      ),
                      const SizedBox(height: 60),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          decoration: BoxDecoration(
                              color: const Color(0xFFF4F4F4),
                              borderRadius: BorderRadius.circular(15)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 5,
                          ),
                          child: const Text(
                            "프로필 수정",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF565656),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 7,
            ),
            color: const Color(0xFFF4F4F4),
            child: Center(
              child: Column(
                children: [
                  Text(
                    "$location, $borrowNum회빌림, $lendNum회 빌려줌",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF565656),
                    ),
                  ),
                  Text(
                    "총 수익: $profit원",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF565656),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
