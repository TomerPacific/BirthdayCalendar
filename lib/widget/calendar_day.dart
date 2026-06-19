import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:birthday_calendar/page/birthdays_for_calendar_day_page/birthdays_for_calendar_day.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/model/birthdays_stream_event.dart';
import 'package:provider/provider.dart';

class CalendarDayWidget extends StatefulWidget {
  final DateTime date;
  final NotificationService notificationService;

  const CalendarDayWidget(
      {required Key key, required this.date, required this.notificationService})
      : super(key: key);

  @override
  _CalendarDayState createState() => _CalendarDayState();
}

class _CalendarDayState extends State<CalendarDayWidget> {
  List<UserBirthday> _birthdays = [];
  late StreamSubscription<BirthdaysStreamEvent> _streamSubscription;

  @override
  void initState() {
    unawaited(_fetchBirthdaysFromStorage());
    Stream<BirthdaysStreamEvent> stream =
        context.read<StorageService>().getBirthdaysStream();
    _streamSubscription = stream.listen(_handleEventFromStorageService);
    super.initState();
  }

  void _handleEventFromStorageService(BirthdaysStreamEvent event) {
    if (!mounted) {
      return;
    }

    if (event.date.month == widget.date.month &&
        event.date.day == widget.date.day) {
      setState(() {
        _birthdays.removeWhere((element) =>
            element.birthdayDate.year == event.date.year &&
            element.birthdayDate.month == event.date.month &&
            element.birthdayDate.day == event.date.day);
        _birthdays.addAll(event.birthdays);
      });
    }
  }

  @override
  void didUpdateWidget(CalendarDayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    unawaited(_fetchBirthdaysFromStorage());
  }

  Future<void> _fetchBirthdaysFromStorage() async {
    final storageService = context.read<StorageService>();
    try {
      List<UserBirthday> storedBirthdays = await storageService
          .getBirthdaysForDate(widget.date, true);

      if (!mounted) return;

      setState(() {
        _birthdays = storedBirthdays;
      });
    } catch (e) {
      debugPrint("Failed to fetch birthdays from storage: $e");
    }
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
          unawaited(Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BirthdaysForCalendarDayWidget(
                    key: Key(widget.date.toString()),
                    dateOfDay: widget.date,
                    birthdays: _birthdays,
                    notificationService: widget.notificationService),
              )).then((value) => _fetchBirthdaysFromStorage()));
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
