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

  @override
  void initState() {
    super.initState();
    datetimeText = widget.initialText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFB900),
        borderRadius: BorderRadius.circular(.0),
      ),
      child: TextButton(
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
            });
          }, currentTime: DateTime.now(), locale: LocaleType.ko);
        },
        child: Text(
          datetimeText,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
