
import 'package:flutter/material.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/service/shared_prefs.dart';
import 'package:birthday_calendar/service/notification_service.dart';

class BirthdayWidget extends StatefulWidget {

  final UserBirthday birthdayOfPerson;
  final VoidCallback onDeletePressedCallback;

  BirthdayWidget({Key key, @required this.birthdayOfPerson, @required this.onDeletePressedCallback}) : super(key: key);

  @override _BirthdayWidgetState createState() => _BirthdayWidgetState();

}

class _BirthdayWidgetState extends State<BirthdayWidget> {

  bool isNotificationEnabledForPerson = false;

  void updateNotificationStatusForBirthday() {
    SharedPrefs().updateNotificationStatusForBirthday(widget.birthdayOfPerson, !isNotificationEnabledForPerson);
    setState(() {
      isNotificationEnabledForPerson = !isNotificationEnabledForPerson;
    });
  }

  @override void initState() {
    isNotificationEnabledForPerson = widget.birthdayOfPerson.hasNotification;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: Colors.indigoAccent,
      child: Row(
        children: [
          new Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.birthdayOfPerson.name,
              style: new TextStyle(
                  fontSize: 20.0,
                  color: Colors.white
              ),
            ),
          ),
          new Spacer(),
          new IconButton(
              icon: Icon(
                  isNotificationEnabledForPerson ?
                  Icons.notifications_off_outlined :
                  Icons.notifications_active_outlined,
                  color: Colors.white
              ),
              onPressed: () {
                updateNotificationStatusForBirthday();
              }),
          new IconButton(
              icon: Icon(
                  Icons.clear,
                  color: Colors.white
              ),
              onPressed: widget.onDeletePressedCallback
          ),
        ],
      ),
    );
  }

}
