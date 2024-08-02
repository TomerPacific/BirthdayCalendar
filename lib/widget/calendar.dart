import 'package:birthday_calendar/BirthdayCalendarDateUtils.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:birthday_calendar/widget/calendar_day.dart';

class CalendarWidget extends StatefulWidget {
  final int currentMonth;
  final NotificationService notificationService;

  const CalendarWidget(
      {required Key key,
      required this.currentMonth,
      required this.notificationService})
      : super(key: key);

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<CalendarWidget> {
  int _amountOfDaysToPresent = 0;

  @override
  void initState() {
    _amountOfDaysToPresent = BirthdayCalendarDateUtils.amountOfDaysInMonth(
        BirthdayCalendarDateUtils.convertMonthToWord(widget.currentMonth));
    super.initState();
  }

  @override
  void didUpdateWidget(CalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _amountOfDaysToPresent = BirthdayCalendarDateUtils.amountOfDaysInMonth(
        BirthdayCalendarDateUtils.convertMonthToWord(widget.currentMonth));
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new SizedBox(
          height: (MediaQuery.of(context).size.height),
          child: new GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5),
              itemCount: _amountOfDaysToPresent,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return new CalendarDayWidget(
                    key: Key(widget.currentMonth.toString()),
                    date: BirthdayCalendarDateUtils
                        .constructDateTimeFromDayAndMonth(
                            (index + 1), widget.currentMonth),
                    notificationService: widget.notificationService);
              })),
    );
  }
}
