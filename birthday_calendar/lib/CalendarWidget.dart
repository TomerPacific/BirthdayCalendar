
import 'package:flutter/material.dart';
import 'package:birthday_calendar/DateService.dart';

class CalendarWidget extends StatefulWidget {
  final int currentMonth;

  const CalendarWidget({Key key, this.currentMonth}) : super(key: key);

  @override _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<CalendarWidget> {

  int _amountOfDaysToPresent = 0;

  @override void initState() {
    _amountOfDaysToPresent = DateService().amountOfDaysInMonth(DateService().convertMonthToWord(widget.currentMonth));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (MediaQuery.of(context).size.height),
      child: GridView.builder(gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount : 5),
          itemCount: _amountOfDaysToPresent,
          itemBuilder: (BuildContext context, int index) {
            return TextButton(onPressed: () {},
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(DateService().getDayFromDate(
                      DateService().constructDateForDay(++index,
                          widget.currentMonth)
                    )
                  )
                )
            );
          }
      ),
    );
  }
}