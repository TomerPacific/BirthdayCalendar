
import 'package:flutter/material.dart';
import 'dart:async';
import 'birthdays_for_calendar_day.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import '../service/storage_service/storage_service.dart';
import 'package:birthday_calendar/service/service_locator.dart';

class CalendarDayWidget extends StatefulWidget {
  final DateTime date;

  const CalendarDayWidget({required Key key, required this.date}) : super(key: key);

  @override
  _CalendarDayState createState() => _CalendarDayState();
}

class _CalendarDayState extends State<CalendarDayWidget> {
  List<UserBirthday> _birthdays = [];
  StorageService _storageService = getIt<StorageService>();
  late StreamSubscription<List<UserBirthday>> _streamSubscription;

  @override
  void initState() {
    _fetchBirthdaysFromStorage();
    Stream<List<UserBirthday>> stream = _storageService.getBirthdaysStream();
    _streamSubscription = stream.listen(_handleEventFromStorageService);
    super.initState();
  }

  void _handleEventFromStorageService(List<UserBirthday> event) {
    List<UserBirthday> receivedBirthdays = [];
    for(UserBirthday birthday in event) {

      DateTime firstDateWithoutYear = new DateTime(birthday.birthdayDate.month, birthday.birthdayDate.day);
      DateTime secondDateWithoutYear = new DateTime(widget.date.month, widget.date.day);

      if (firstDateWithoutYear == secondDateWithoutYear && !receivedBirthdays.contains(birthday)) {
        receivedBirthdays.add(birthday);
      }
    }

    if (receivedBirthdays.length > 0) {
      setState(() {
        _birthdays = receivedBirthdays;
      });
    }

  }

  @override
  void didUpdateWidget(CalendarDayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fetchBirthdaysFromStorage();
  }

  void _fetchBirthdaysFromStorage() async {
    List<UserBirthday> storedBirthdays = await _storageService.getBirthdaysForDate(widget.date);
    setState(() {
      _birthdays = storedBirthdays;
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
                  key: Key(widget.date.toString()),
                  dateOfDay: widget.date,
                  birthdays: _birthdays),
              )).then((value) => _fetchBirthdaysFromStorage());
        },
        child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Column(children: [
              Text(widget.date.day.toString(),
                style:  new TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold)
              ),
              if (_birthdays.length > 0)
                _showBirthdayIcon()
            ])));
  }

  @override void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }
}
