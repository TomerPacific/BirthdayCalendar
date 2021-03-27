
import 'package:flutter/material.dart';

class CalendarWidget extends StatefulWidget {
  final int currentMonth;

  const CalendarWidget({Key key, this.currentMonth}) : super(key: key);

  @override _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<CalendarWidget> {

  @override void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Column(
            children: [

            ],
          )
        ],
      ),
    );
  }

}