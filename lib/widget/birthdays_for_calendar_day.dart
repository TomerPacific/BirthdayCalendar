
import 'package:flutter/material.dart';
import 'package:birthday_calendar/widget/birthday.dart';
import 'package:birthday_calendar/widget/add_birthday_form.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import '../service/storage_service/storage_service.dart';
import 'package:birthday_calendar/service/service_locator.dart';
import '../service/date_service/date_service.dart';
import '../service/notification_service/notification_service.dart';

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
      _notificationService.scheduleNotificationForBirthday(userBirthday, "${userBirthday.name} has an upcoming birthday!");
  }

  void _addBirthdayToList(UserBirthday userBirthday) {
    setState(() {
      currentBirthdays.add(userBirthday);
    });

    List<UserBirthday> birthdaysMatchingDate = currentBirthdays.where((element) => element.birthdayDate == userBirthday.birthdayDate).toList();
    _storageService.saveBirthdaysForDate(widget.dateOfDay, birthdaysMatchingDate);
  }

  void _removeBirthdayFromList(UserBirthday birthdayToRemove) async {
    setState(() {
      currentBirthdays.remove(birthdayToRemove);
    });

    List<UserBirthday> birthdaysForDateDeleted = await _storageService.getBirthdaysForDate(birthdayToRemove.birthdayDate, false);
    bool found = false;
    int i = 0;
    for (; i < birthdaysForDateDeleted.length && !found; i++) {
      if (birthdaysForDateDeleted[i].equals(birthdayToRemove)) {
        found = true;
      }
    }

    if (found) {
      birthdaysForDateDeleted.removeAt(--i);
    }
    _storageService.saveBirthdaysForDate(birthdayToRemove.birthdayDate, birthdaysForDateDeleted);
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
