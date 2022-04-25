
import 'package:birthday_calendar/page/birthdays_for_calendar_day_page/birthdays_for_calendar_day_manager.dart';
import 'package:flutter/material.dart';
import 'package:birthday_calendar/page/birthday/birthday.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/service/service_locator.dart';
import 'package:birthday_calendar/service/date_service/date_service.dart';
import 'package:provider/provider.dart';

class BirthdaysForCalendarDayWidget extends StatelessWidget {
  final DateTime dateOfDay;
  final List<UserBirthday> birthdays;

  BirthdaysForCalendarDayWidget(
      {required Key key, required this.dateOfDay, required this.birthdays})
      : super(key: key);

  final DateService _dateService = getIt<DateService>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BirthdaysForCalendarDayManager(this.birthdays, this.dateOfDay),
          builder: (context, provider) {
              return Scaffold(
              appBar: AppBar(
              title: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                      "Birthdays for ${_dateService.convertMonthToWord(this.dateOfDay.month)} ${this.dateOfDay.day}")
              )
          ),
            body: Center(
                child: Column(
                  children: [
                      Consumer<BirthdaysForCalendarDayManager>(
                          builder: (context, data, child) =>
                          Expanded(child:
                            ListView.builder(
                                  itemCount: data.birthdays.length,
                                  itemBuilder: (BuildContext context, int index) {
                                  return BirthdayWidget(
                                    key: Key(data.birthdays[index].name),
                                      birthdayOfPerson: data.birthdays[index],
                                      onDeletePressedCallback: () {
                                        Provider.of<BirthdaysForCalendarDayManager>(context, listen: false).removeBirthdayFromList(data.birthdays[index]);
                                    },
                                    indexOfBirthday: index);
                                  },
                                 ),
                           ),
                          )
                      ],
                   )
                ),
                floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Provider.of<BirthdaysForCalendarDayManager>(context, listen: false).handleAddBirthdayBtnPressed(context, dateOfDay);
                  },
                child: Icon(Icons.add)),
              );
          },
    );
  }
}
