import 'package:flutter/material.dart';

import 'birthdays_for_calendar_day.dart';
import 'package:birthday_calendar/service/shared_prefs.dart';
import 'package:birthday_calendar/model/user_birthday.dart';

class CalendarDayWidget extends StatefulWidget {
  final DateTime date;

  const CalendarDayWidget({Key key, this.date}) : super(key: key);

  @override
  _CalendarDayState createState() => _CalendarDayState();
}

class _CalendarDayState extends State<CalendarDayWidget> {
  List<UserBirthday> _birthdays = [];

  @override
  void initState() {
    _fetchBirthdaysFromStorage();
    super.initState();
  }

  @override
  void didUpdateWidget(CalendarDayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fetchBirthdaysFromStorage();
  }

  void _fetchBirthdaysFromStorage() {
    setState(() {
      _birthdays = SharedPrefs().getBirthdaysForDate(widget.date);
    });
  }

  Widget _showBirthdayIcon() {
    return Icon(
      Icons.cake_outlined,
      color: Colors.pink,
      size: 24.0,
    );
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
              )).then((value) => _fetchBirthdaysFromStorage());
        },
        child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Column(children: [
              Text(widget.date.day.toString(),
                style:  new TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold)
              ),
              if (_birthdays != null && _birthdays.length > 0)
                _showBirthdayIcon()
            ])));
  }
}
