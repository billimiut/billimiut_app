import 'package:billimiut_app/widgets/postList.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:billimiut_app/providers/posts.dart';
import 'package:provider/provider.dart';
import 'package:billimiut_app/screens/post_info_screen.dart';

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
    filteredPostsList.sort((a, b) {
      var timeA = a['post_time'];
      var timeB = b['post_time'];

      DateTime dateA;
      DateTime dateB;

      // Firestore Timestamp인 경우 처리
      if (timeA is Timestamp) {
        dateA = timeA.toDate();
      } else if (timeA is String) {
        dateA = DateTime.parse(timeA);
      } else {
        dateA = DateTime.now(); // 만약 데이터가 없으면 현재 시간으로 설정
      }

      if (timeB is Timestamp) {
        dateB = timeB.toDate();
      } else if (timeB is String) {
        dateB = DateTime.parse(timeB);
      } else {
        dateB = DateTime.now(); // 만약 데이터가 없으면 현재 시간으로 설정
      }

      // 내림차순 정렬
      return dateB.compareTo(dateA);
    });

    return ListView.builder(
        itemCount: filteredPostsList.length,
        itemBuilder: (context, index) {
          var post = filteredPostsList[index];
          return PostList(
            post: post,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailPage(docId: post['post_id']),
                ),
              );
            },
          );
        });
  }
}
