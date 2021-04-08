
import 'package:birthday_calendar/model/userBirthday.dart';
import 'package:birthday_calendar/service/DateService.dart';
import 'package:flutter/material.dart';
import 'package:birthday_calendar/service/SharedPrefs.dart';
import '../BirthdayPage.dart';

class CalendarDayWidget extends StatefulWidget {

  final int dayNumber;
  final int month;

  const CalendarDayWidget({Key key, this.month, this.dayNumber}) : super(key: key);

  @override _CalendarDayState createState() => _CalendarDayState();
}

class _CalendarDayState extends State<CalendarDayWidget> {

  List<UserBirthday> _birthdays = [];

  @override void initState() {
    _fetchBirthdaysFromStorage();
    super.initState();
  }

  String _formatDayDate() {
    return DateService().convertMonthToWord(widget.month) + " " + widget.dayNumber.toString();
  }

  String _getDayOfDate() {
    DateTime dayAsDate = DateService().constructDateForDay(widget.dayNumber, widget.month);
    return DateService().getDayFromDate(dayAsDate);
  }

  void _fetchBirthdaysFromStorage() {
    _birthdays = SharedPrefs().getBirthdaysForDate(_formatDayDate());
  }

  Widget _showBirthdayIcon() {
      return  Icon(
        Icons.cake_outlined,
        color: Colors.pink,
        size: 24.0,
      );
  }

  void _updateBirthdayData() {
    _fetchBirthdaysFromStorage();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BirthdayPage(
                    dateOfDay: _formatDayDate(),
                    birthdays: _birthdays != null ? _birthdays : []),
              )).then((value) =>
                  _updateBirthdayData()
              );
        },
        child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Column(
              children: [
                Text(_formatDayDate()),
                Text(_getDayOfDate()),
                if (_birthdays != null && _birthdays.length > 0) _showBirthdayIcon()
              ]
            )
        )
    );
  }
}