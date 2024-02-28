import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String titleText;
  final String contentText;
  final List<Widget> actionWidgets;

  const CustomAlertDialog({
    super.key,
    required this.titleText,
    required this.contentText,
    required this.actionWidgets,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        titleText,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF565656),
        ),
      ),
      content: Text(
        contentText,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF565656),
        ),
      ),
      actions: actionWidgets,
    );
  }
}
