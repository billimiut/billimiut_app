import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';

class DateTimePicker extends StatefulWidget {
  final String initialText;
  final Function(DateTime) onDateSelected;

  const DateTimePicker(
      {Key? key, required this.initialText, required this.onDateSelected})
      : super(key: key);

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
    return TextButton(
      onPressed: () {
        DatePicker.showDateTimePicker(context,
            showTitleActions: true,
            minTime: DateTime(2023, 1, 1),
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
      ),
    );
  }
}
