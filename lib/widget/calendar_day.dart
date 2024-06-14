import 'package:birthday_calendar/service/date_service/date_service.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:birthday_calendar/page/birthdays_for_calendar_day_page/birthdays_for_calendar_day.dart';
import 'package:birthday_calendar/model/user_birthday.dart';

class CalendarDayWidget extends StatefulWidget {
  final DateTime date;
  final StorageService storageService;
  final DateService dateService;
  final NotificationService notificationService;

  const CalendarDayWidget(
      {required Key key,
      required this.date,
      required this.storageService,
      required this.dateService,
      required this.notificationService})
      : super(key: key);

  @override
  _CalendarDayState createState() => _CalendarDayState();
}

class _CalendarDayState extends State<CalendarDayWidget> {
  List<UserBirthday> _birthdays = [];
  late StreamSubscription<List<UserBirthday>> _streamSubscription;

  @override
  void initState() {
    _fetchBirthdaysFromStorage();
    Stream<List<UserBirthday>> stream =
        widget.storageService.getBirthdaysStream();
    _streamSubscription = stream.listen(_handleEventFromStorageService);
    super.initState();
  }

  void _handleEventFromStorageService(List<UserBirthday> event) {
    List<UserBirthday> currentBirthdays = _birthdays;
    for (UserBirthday birthday in event) {
      DateTime firstDateWithoutYear =
          new DateTime(birthday.birthdayDate.month, birthday.birthdayDate.day);
      DateTime secondDateWithoutYear =
          new DateTime(widget.date.month, widget.date.day);

      if (firstDateWithoutYear == secondDateWithoutYear &&
          !currentBirthdays.contains(birthday)) {
        currentBirthdays.add(birthday);
      }
    }

    if (currentBirthdays.length > 0) {
      setState(() {
        _birthdays = currentBirthdays;
      });
    }
  }

  @override
  void didUpdateWidget(CalendarDayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _fetchBirthdaysFromStorage();
  }

  void _fetchBirthdaysFromStorage() async {
    List<UserBirthday> storedBirthdays =
        await widget.storageService.getBirthdaysForDate(widget.date, true);
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
                    birthdays: _birthdays,
                    dateService: widget.dateService,
                    storageService: widget.storageService,
                    notificationService: widget.notificationService),
              )).then((value) => _fetchBirthdaysFromStorage());
        },
        child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Column(children: [
              Text(widget.date.day.toString(),
                  style: new TextStyle(
                      fontSize: 15.0, fontWeight: FontWeight.bold)),
              if (_birthdays.length > 0) _showBirthdayIcon()
            ])));
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }
}
