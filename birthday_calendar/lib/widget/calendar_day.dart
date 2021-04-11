
import 'package:flutter/material.dart';


import 'birthdays_for_calendar_day.dart';
import 'package:birthday_calendar/service/date_service.dart';
import 'package:birthday_calendar/service/shared_prefs.dart';
import 'package:birthday_calendar/model/user_birthday.dart';

class CalendarDayWidget extends StatefulWidget {

  final DateTime date;

  const CalendarDayWidget({Key key, this.date}) : super(key: key);

  @override _CalendarDayState createState() => _CalendarDayState();
}

class _CalendarDayState extends State<CalendarDayWidget> {

  List<UserBirthday> _birthdays = [];

  @override void initState() {
    _fetchBirthdaysFromStorage();
    super.initState();
  }

  void _fetchBirthdaysFromStorage() {
    _birthdays = SharedPrefs().getBirthdaysForDate(widget.date);
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
                builder: (context) => BirthdaysForCalendarDayWidget(
                    dateOfDay: widget.date,
                    birthdays: _birthdays != null ? _birthdays : []),
              )).then((value) =>
                  _updateBirthdayData()
              );
        },
        child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Column(
              children: [
                Text(DateService().convertMonthToWord(widget.date.month)),
                Text(widget.date.day.toString()),
                if (_birthdays != null && _birthdays.length > 0) _showBirthdayIcon()
              ]
            )
        )
    );
  }
}