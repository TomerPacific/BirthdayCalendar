
import 'package:flutter/material.dart';

class DayWidget extends StatefulWidget {

  final int dayNumber;

  const DayWidget({Key key, this.dayNumber}) : super(key: key);

  @override _DayState createState() => _DayState();
}


class _DayState extends State<DayWidget> {

  @override
  Widget build(BuildContext context) {
    return Text(widget.dayNumber.toString());
  }
}