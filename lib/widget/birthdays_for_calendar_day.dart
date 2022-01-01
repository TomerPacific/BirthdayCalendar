import 'package:birthday_calendar/widget/add_birthday_form.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import 'package:birthday_calendar/widget/birthday.dart';
import 'package:birthday_calendar/constants.dart';
import 'package:birthday_calendar/service/date_service.dart';
import 'package:birthday_calendar/service/notification_service.dart';
import 'package:birthday_calendar/service/shared_prefs.dart';
import 'package:birthday_calendar/model/user_birthday.dart';

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
  TextEditingController _birthdayPersonController = new TextEditingController();
  TextEditingController _phoneNumberController = new TextEditingController();
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'US');

  bool _isValidName(String userInput) {
    return (userInput.isNotEmpty && userInput.length > 0);
  }

  bool _isUniqueName(String name) {
    UserBirthday? birthday =
        currentBirthdays.firstWhereOrNull((element) => element.name == name);
    return birthday == null;
  }

  void _handleUserInput(String name, String phoneNumber) {
    if (_isValidName(name) && _isUniqueName(name)) {
      UserBirthday userBirthday =
          new UserBirthday(name, widget.dateOfDay, false, phoneNumber);
      _addBirthdayToList(userBirthday);
      _birthdayPersonController.text = "";
      NotificationService().scheduleNotificationForBirthday(
          userBirthday, "${userBirthday.name} has an upcoming birthday!");
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          new SnackBar(content: new Text(invalidNameErrorMessage)));
    }
  }

  void _addBirthdayToList(UserBirthday userBirthday) {
    setState(() {
      currentBirthdays.add(userBirthday);
    });
    SharedPrefs().setBirthdaysForDate(widget.dateOfDay, currentBirthdays);
  }

  void _removeBirthdayFromList(UserBirthday birthdayToRemove) {
    setState(() {
      currentBirthdays.remove(birthdayToRemove);
    });
    SharedPrefs().setBirthdaysForDate(widget.dateOfDay, currentBirthdays);

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
                  "Birthdays for ${DateService().convertMonthToWord(widget.dateOfDay.month)} ${widget.dateOfDay.day}")
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
          onPressed: () {
            showDialog(context: context,
                builder: (_) => AddBirthdayForm());
          },
          child: Icon(Icons.add)),
    );
  }

  @override dispose() {
    _birthdayPersonController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }
}
