import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class BirthdayPage extends StatelessWidget {

  final String dateOfDay;
  final List<String> birthdays;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  BirthdayPage({Key key, @required this.dateOfDay, @required this.birthdays}) : super(key: key);

  void _addBirthdayToList(String birthday) async {
    List<String> updatedBirthdays = birthdays;
    updatedBirthdays.add(birthday);
    final SharedPreferences prefs = await _prefs;
    prefs.setStringList(dateOfDay, updatedBirthdays);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Birthdays for $dateOfDay")),
      body: Center(
        child:
            Column(
              children: [
                Expanded(child:
                  ListView.builder(
                    itemCount: birthdays.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                          height: 50,
                          color: Colors.blueAccent,
                          child: Text("${birthdays[index]}")
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