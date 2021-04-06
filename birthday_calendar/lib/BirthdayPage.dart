import 'package:flutter/material.dart';
import 'package:birthday_calendar/service/SharedPrefs.dart';
import 'package:birthday_calendar/birthday.dart';

class BirthdayPage extends StatefulWidget {

  final String dateOfDay;
  final List<String> birthdays;

  BirthdayPage({Key key, @required this.dateOfDay, @required this.birthdays})
      : super(key: key);

  @override _BirthdayPageState createState() => _BirthdayPageState();

}

class _BirthdayPageState extends State<BirthdayPage> {

  List<String> currentBirthdays;
  TextEditingController _birthdayPersonController = new TextEditingController();

  void _showAddBirthdayDialog(BuildContext context) {
    showDialog(context: context,
      builder: (_) => new AlertDialog(title: new Text("Add Birthday"),
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
              _addBirthdayToList(_birthdayPersonController.text);
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

  void _addBirthdayToList(String birthday) {
    currentBirthdays.add(birthday);
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
                      return Birthday(birthdayOfPerson: currentBirthdays[index]);
                    },
                  ),
                ),
                TextButton(
                    onPressed: () {
                      _showAddBirthdayDialog(context);
                    },
                    child: Text("Add Birthday")
                )
              ],
            )

      ),
    );
  }

}