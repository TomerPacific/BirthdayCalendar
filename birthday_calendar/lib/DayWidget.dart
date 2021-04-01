
import 'package:birthday_calendar/DateService.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import 'BirthdayPage.dart';

class DayWidget extends StatefulWidget {

  final int dayNumber;
  final int month;

  const DayWidget({Key key, this.month, this.dayNumber}) : super(key: key);

  @override _DayState createState() => _DayState();
}

class _DayState extends State<DayWidget> {

  List<String> _birthdays = [];
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

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

  void _fetchBirthdaysFromStorage() async{
    final SharedPreferences prefs = await _prefs;
    _birthdays = prefs.getStringList(_formatDayDate());
  }

  Widget _showBirthdayIcon() {
      return  Icon(
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
                builder: (context) => BirthdayPage(
                    dateOfDay: _formatDayDate(),
                    birthdays: _birthdays != null ? _birthdays : []),
              )).then((value) => setState(() => {}));
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