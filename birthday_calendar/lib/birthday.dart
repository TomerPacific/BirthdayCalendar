
import 'package:flutter/material.dart';
import 'package:birthday_calendar/model/userBirthday.dart';
import 'package:birthday_calendar/service/SharedPrefs.dart';

class Birthday extends StatefulWidget {

  final UserBirthday birthdayOfPerson;

  Birthday({Key key, @required this.birthdayOfPerson}) : super(key: key);

  @override _BirthdayState createState() => _BirthdayState();

}

class _BirthdayState extends State<Birthday> {

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
              onPressed: () {})
        ],
      ),
    );
  }

}
