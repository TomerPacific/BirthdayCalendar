
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
      height: 40,
      color: Colors.indigoAccent,
      child: Row(
        children: [
          new Text(widget.birthdayOfPerson,
          style: new TextStyle(
            fontSize: 20.0,
            color: Colors.white
          ),
          ),
          new Spacer(),
          new IconButton(
              icon: Icon(
                  Icons.edit,
                  color: Colors.white
              ),
              onPressed: () {}),
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
