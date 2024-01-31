import 'package:flutter/material.dart';

class BorrowLendToggle extends StatefulWidget {
  final Function onBorrowPressed;
  final Function onLendPressed;

  const BorrowLendToggle(
      {super.key, required this.onBorrowPressed, required this.onLendPressed});

  @override
  _BorrowLendToggleState createState() => _BorrowLendToggleState();
}

class _BorrowLendToggleState extends State<BorrowLendToggle> {
  final List<bool> _isSelected = [true, false];

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
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

        if (newIndex == 0) {
          widget.onBorrowPressed();
        } else {
          widget.onLendPressed();
        }
      },
      children: const <Widget>[
        Text(
          '빌림',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        Text(
          '빌려줌',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
