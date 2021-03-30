
import 'package:flutter/material.dart';

class DayWidget extends StatefulWidget {

  final int dayNumber;
  final String month;

  const DayWidget({Key key, this.month, this.dayNumber}) : super(key: key);

  @override _DayState createState() => _DayState();
}


class _DayState extends State<DayWidget> {

  String _formatDayDate() {
    return widget.month + " " + widget.dayNumber.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_formatDayDate());
  }
}