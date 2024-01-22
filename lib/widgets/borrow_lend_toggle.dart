import 'package:flutter/material.dart';

class BorrowLendToggle extends StatefulWidget {
  @override
  _BorrowLendToggleState createState() => _BorrowLendToggleState();
}

class _BorrowLendToggleState extends State<BorrowLendToggle> {
  List<bool> _isSelected = [true, false];

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      children: <Widget>[
        Text('빌림'),
        Text('빌려줌'),
      ],
      isSelected: _isSelected,
      onPressed: (int newIndex) {
        setState(() {
          for (int index = 0; index < _isSelected.length; index++) {
            if (index == newIndex) {
              _isSelected[index] = true;
            } else {
              _isSelected[index] = false;
            }
          }
        });
      },
    );
  }
}
