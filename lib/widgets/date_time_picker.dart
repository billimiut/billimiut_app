import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';

class DateTimePicker extends StatefulWidget {
  final String initialText;
  final Function(DateTime) onDateSelected;

  const DateTimePicker(
      {super.key, required this.initialText, required this.onDateSelected});

  @override
  State<DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  late String datetimeText;
  Color containerColor = const Color(0xFFF4F4F4);
  Color textColor = const Color(0xff007DFF);
  FontWeight fontWeight = FontWeight.w400;

  @override
  void initState() {
    super.initState();
    datetimeText = widget.initialText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        child: Text(
          datetimeText,
          style: TextStyle(
            fontSize: 12,
            fontWeight: fontWeight,
            color: textColor,
          ),
        ),
        onPressed: () {
          DatePicker.showDateTimePicker(context,
              showTitleActions: true,
              minTime: DateTime.now(),
              maxTime: DateTime(2024, 12, 31),
              onChanged: (date) {}, onConfirm: (date) {
            setState(() {
              DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
              datetimeText = formatter.format(date);
              widget.onDateSelected(date);
              Color tempColor = containerColor;
              containerColor = textColor;
              textColor = tempColor;
              fontWeight = FontWeight.w600;
            });
          }, currentTime: DateTime.now(), locale: LocaleType.ko);
        },
      ),
    );
  }
}
