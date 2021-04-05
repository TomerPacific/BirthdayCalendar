import 'package:flutter/material.dart';
import 'package:birthday_calendar/service/SharedPrefs.dart';

class BirthdayPage extends StatefulWidget {

  final String dateOfDay;
  final List<String> birthdays;

  BirthdayPage({Key key, @required this.dateOfDay, @required this.birthdays})
      : super(key: key);

  @override _BirthdayPageState createState() => _BirthdayPageState();

}

class _BirthdayPageState extends State<BirthdayPage> {

  List<String> currentBirthdays;

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
                      return Container(
                          height: 50,
                          color: Colors.blueAccent,
                          child: Text("${currentBirthdays[index]}")
                      );
                    },
                  ),
                ),
                TextButton(
                    onPressed: () {

                    },
                    child: Text("Add Birthday")
                )
              ],
            )

      ),
    );
  }

}