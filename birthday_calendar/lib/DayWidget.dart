
import 'package:birthday_calendar/DateService.dart';
import 'package:flutter/material.dart';

class DayWidget extends StatefulWidget {

  final int dayNumber;
  final int month;

  const DayWidget({Key key, this.month, this.dayNumber}) : super(key: key);

  @override _DayState createState() => _DayState();
}

class _DayState extends State<DayWidget> {

  bool _hasBirthdays = false;

  String _formatDayDate() {
    return DateService().convertMonthToWord(widget.month) + " " + widget.dayNumber.toString();
  }

  String _getDayOfDate() {
    DateTime dayAsDate = DateService().constructDateForDay(widget.dayNumber, widget.month);
    return DateService().getDayFromDate(dayAsDate);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {},
        child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Column(
              children: [
                Text(_formatDayDate()),
                Text(_getDayOfDate()),
                if (_hasBirthdays) Icon(
                  Icons.cake_outlined,
                  color: Colors.pink,
                  size: 24.0,
                  semanticLabel: 'Text to announce in accessibility modes',
                )
              ]
            )
        )
    );
  }
}