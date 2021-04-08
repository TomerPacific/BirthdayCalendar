import 'package:birthday_calendar/model/userBirthday.dart';
import 'package:flutter/material.dart';
import 'package:birthday_calendar/service/SharedPrefs.dart';
import 'package:birthday_calendar/BirthdayWidget.dart';
import 'package:birthday_calendar/constants.dart';

class BirthdaysForCalendarDayWidget extends StatefulWidget {

  final String dateOfDay;
  final List<UserBirthday> birthdays;

  BirthdaysForCalendarDayWidget({Key key, @required this.dateOfDay, @required this.birthdays})
      : super(key: key);

  @override _BirthdaysForCalendarDayWidgetState createState() => _BirthdaysForCalendarDayWidgetState();

}

class _BirthdaysForCalendarDayWidgetState extends State<BirthdaysForCalendarDayWidget> {

  List<UserBirthday> currentBirthdays;
  TextEditingController _birthdayPersonController = new TextEditingController();

  void _showAddBirthdayDialog(BuildContext context) {
    showDialog(context: context,
      builder: (_) => new AlertDialog(title: new Text(ADD_BIRTHDAY),
        content: new TextField(
            autofocus: true,
            controller: _birthdayPersonController,
            decoration: InputDecoration(hintText: "Enter the person's name"),
            ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
                primary: Colors.green
            ),
            onPressed: () {
              UserBirthday userBirthday = new UserBirthday(_birthdayPersonController.text, widget.dateOfDay, false);
              _addBirthdayToList(userBirthday);
              Navigator.pop(context);
            },
            child: new Text("OK"),
          ),
          TextButton(
            style: TextButton.styleFrom(
                primary: Colors.red
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: new Text("BACK"),
          )
        ],
      ),
    );
  }

  void _addBirthdayToList(UserBirthday userBirthday) {
    currentBirthdays.add(userBirthday);
    SharedPrefs().setBirthdaysForDate(widget.dateOfDay, currentBirthdays);
    setState(() {});
  }

  @override void initState() {
    currentBirthdays = widget.birthdays;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:
      FittedBox(
        fit: BoxFit.fitWidth,
        child: Text("Birthdays for ${widget.dateOfDay}"))
      ),
      body: Center(
        child:
            Column(
              children: [
                Expanded(child:
                  ListView.builder(
                    itemCount: currentBirthdays.length,
                    itemBuilder: (BuildContext context, int index) {
                      return BirthdayWidget(birthdayOfPerson: currentBirthdays[index]);
                    },
                  ),
                ),
                TextButton(
                    onPressed: () {
                      _showAddBirthdayDialog(context);
                    },
                    child: Text(ADD_BIRTHDAY)
                )
              ],
            )

      ),
    );
  }

}