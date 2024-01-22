import 'package:firebase_database/firebase_database.dart';

import '../models/post.dart';

class DatabaseSvc {
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  void writeDB() async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("postdb/userId1/postkey");
    await ref.set({
      "title": "title",
      "item": "item",
      "money": "money",
      "startDate": "startDate",
      "endDate": "endDate",
      "location": "location",
      "borrow": "borrow",
      "imageUrl": "imageUrl",
      "description": "description"
    });
  }

  void readDB() {
    DatabaseReference starCountRef =
        FirebaseDatabase.instance.ref('postdb/userId1');
    starCountRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      if (data.isEmpty) {
        print('no data');
        return;
      }
      final posts = <Post>[];
      for (final key in data.keys) {
        final postvalue = data[key];
        final book = Post.fromMap(postvalue);
      }
      print("posts $posts");
      // updateStarCount(data);
    });
  }
}
/*JSON
postdb
  UserID1
    postlist
      postkey1
        title
        item
        money
        '''
  UserID2
    postlist
      postkey1
        title
        item
        money
        '''
*/