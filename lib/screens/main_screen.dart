import 'package:billimiut_app/services/databaseSvc.dart';
import 'package:billimiut_app/widgets/borrow_lend_toggle.dart';
import 'package:billimiut_app/widgets/image_uploader.dart';
import 'package:billimiut_app/widgets/location_picker.dart';
import 'package:flutter/material.dart';
import '../widgets/date_time_picker.dart';
import '../widgets/post_writing_text.dart';
import '../models/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return Row();
      },
      itemCount: 10,
    );
  }
}
