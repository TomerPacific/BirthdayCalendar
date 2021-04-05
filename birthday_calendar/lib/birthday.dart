
import 'package:flutter/material.dart';

class Birthday extends StatefulWidget {

  final String birthdayOfPerson;

  Birthday({Key key, @required this.birthdayOfPerson}) : super(key: key);

  @override _BirthdayState createState() => _BirthdayState();

}

class _BirthdayState extends State<Birthday> {


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Text(widget.birthdayOfPerson)
        ],
      ),
    );
  }

}
