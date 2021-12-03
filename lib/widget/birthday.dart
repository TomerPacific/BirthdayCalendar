import 'package:flutter/material.dart';

import 'package:birthday_calendar/service/notification_service.dart';
import 'package:birthday_calendar/service/shared_prefs.dart';
import 'package:birthday_calendar/model/user_birthday.dart';

class BirthdayWidget extends StatefulWidget {
  final UserBirthday birthdayOfPerson;
  final VoidCallback onDeletePressedCallback;
  final int indexOfBirthday;

  BirthdayWidget(
      {required Key key ,
      required this.birthdayOfPerson,
      required this.onDeletePressedCallback,
      required this.indexOfBirthday})
      : super(key: key);

  @override
  _BirthdayWidgetState createState() => _BirthdayWidgetState();
}

class _BirthdayWidgetState extends State<BirthdayWidget> {
  bool isNotificationEnabledForPerson = false;

  void updateNotificationStatusForBirthday() {
    setState(() {
      isNotificationEnabledForPerson = !isNotificationEnabledForPerson;
    });
    SharedPrefs().updateNotificationStatusForBirthday(
        widget.birthdayOfPerson, isNotificationEnabledForPerson);
    if (!isNotificationEnabledForPerson) {
      NotificationService()
          .cancelNotificationForBirthday(widget.birthdayOfPerson);
    } else {
      NotificationService().scheduleNotificationForBirthday(
          widget.birthdayOfPerson,
          "${widget.birthdayOfPerson.name} has an upcoming birthday!");
    }
  }

  Color _getColorBasedOnPosition(int index, String element) {
    if (element == "background") {
      return index % 2 == 0 ? Colors.indigoAccent : Colors.white24;
    }

    return index % 2 == 0 ? Colors.white : Colors.black;
  }

  @override
  void initState() {
    isNotificationEnabledForPerson = widget.birthdayOfPerson.hasNotification;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: _getColorBasedOnPosition(widget.indexOfBirthday, "background"),
      child: Row(
        children: [
          new Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.birthdayOfPerson.name,
              style: new TextStyle(fontSize: 20.0, color: _getColorBasedOnPosition(widget.indexOfBirthday, "text")),
            ),
          ),
          new Spacer(),
          new IconButton(
              icon: Icon(
                  isNotificationEnabledForPerson
                      ? Icons.notifications_off_outlined
                      : Icons.notifications_active_outlined,
                  color:  _getColorBasedOnPosition(widget.indexOfBirthday, "icon")),
              onPressed: () {
                updateNotificationStatusForBirthday();
              }),
          new IconButton(
              icon: Icon(Icons.clear, color: _getColorBasedOnPosition(widget.indexOfBirthday, "icon")),
              onPressed: widget.onDeletePressedCallback),
        ],
      ),
    );
  }
}