import 'package:flutter/material.dart';


class BirthdayPage extends StatelessWidget {

  final String dateOfDay;

  BirthdayPage({Key key, @required this.dateOfDay}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Birthdays for $dateOfDay")),
      body: Center(
        child:
          Text("Birthdays for $dateOfDay"),
      ),
    );
  }

}