import 'package:birthday_calendar/widget/add_birthday_form.dart';
import 'package:flutter/material.dart';

import 'package:birthday_calendar/widget/birthday.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/service/StorageService.dart';
import 'package:birthday_calendar/service/service_locator.dart';
import 'package:birthday_calendar/service/date_service.dart';
import 'package:birthday_calendar/service/notification_service.dart';

class BirthdaysForCalendarDayWidget extends StatefulWidget {
  final DateTime dateOfDay;
  final List<UserBirthday> birthdays;

  BirthdaysForCalendarDayWidget(
      {required Key key, required this.dateOfDay, required this.birthdays})
      : super(key: key);

  @override
  _BirthdaysForCalendarDayWidgetState createState() =>
      _BirthdaysForCalendarDayWidgetState();
}

class _BirthdaysForCalendarDayWidgetState
    extends State<BirthdaysForCalendarDayWidget> {

  List<UserBirthday> currentBirthdays = [];
  StorageService _storageService = getIt<StorageService>();
  DateService _dateService = getIt<DateService>();
  NotificationService _notificationService = getIt<NotificationService>();


  void _handleUserInput(UserBirthday userBirthday) {
      _addBirthdayToList(userBirthday);
      _notificationService.scheduleNotificationForBirthday(
          userBirthday, "${userBirthday.name} has an upcoming birthday!");
  }

  void _addBirthdayToList(UserBirthday userBirthday) {
    setState(() {
      currentBirthdays.add(userBirthday);
    });
    _storageService.saveBirthdaysForDate(widget.dateOfDay, currentBirthdays);
  }

  void _removeBirthdayFromList(UserBirthday birthdayToRemove) {
    setState(() {
      currentBirthdays.remove(birthdayToRemove);
    });
    _storageService.saveBirthdaysForDate(widget.dateOfDay, currentBirthdays);

  }

  @override
  void initState() {
    currentBirthdays = widget.birthdays;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                  "Birthdays for ${_dateService.convertMonthToWord(widget.dateOfDay.month)} ${widget.dateOfDay.day}")
          )
      ),
      body: Center(
          child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: currentBirthdays.length,
              itemBuilder: (BuildContext context, int index) {
                return BirthdayWidget(
                  key: Key(currentBirthdays[index].name),
                  birthdayOfPerson: currentBirthdays[index],
                  onDeletePressedCallback: () {
                      _removeBirthdayFromList(currentBirthdays[index]);
                  },
                  indexOfBirthday: index);
              },
            ),
          ),
        ],
      )
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            var result = await showDialog(context: context,
                builder: (_) => AddBirthdayForm(dateOfDay: widget.dateOfDay));
            if (result != null) {
              _handleUserInput(result);
            }
          },
          child: Icon(Icons.add)),
    );
  }
}
