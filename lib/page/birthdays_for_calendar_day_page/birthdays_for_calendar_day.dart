import 'package:birthday_calendar/page/birthdays_for_calendar_day_page/birthdays_for_calendar_day_manager.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:birthday_calendar/page/birthday/birthday.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/service/date_service/date_service.dart';
import 'package:provider/provider.dart';

class BirthdaysForCalendarDayWidget extends StatelessWidget {
  final DateTime dateOfDay;
  final List<UserBirthday> birthdays;
  final DateService dateService;
  final StorageService storageService;
  final NotificationService notificationService;

  BirthdaysForCalendarDayWidget(
      {required Key key,
      required this.dateOfDay,
      required this.birthdays,
      required this.dateService,
      required this.storageService,
      required this.notificationService})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BirthdaysForCalendarDayManager(
          this.birthdays, this.dateOfDay, notificationService, storageService),
      builder: (context, provider) {
        return Scaffold(
          appBar: AppBar(
              title: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                      "Birthdays for ${dateService.convertMonthToWord(this.dateOfDay.month)} ${this.dateOfDay.day}"))),
          body: Center(
              child: Column(
            children: [
              Consumer<BirthdaysForCalendarDayManager>(
                builder: (context, data, child) => Expanded(
                  child: ListView.builder(
                    itemCount: data.birthdays.length,
                    itemBuilder: (BuildContext context, int index) {
                      return BirthdayWidget(
                          key: Key(data.birthdays[index].name),
                          birthdayOfPerson: data.birthdays[index],
                          onDeletePressedCallback: () {
                            Provider.of<BirthdaysForCalendarDayManager>(context,
                                    listen: false)
                                .removeBirthdayFromList(data.birthdays[index]);
                          },
                          indexOfBirthday: index,
                          storageService: storageService,
                          notificationService: notificationService);
                    },
                  ),
                ),
              )
            ],
          )),
          floatingActionButton: FloatingActionButton(
              onPressed: () {
                Provider.of<BirthdaysForCalendarDayManager>(context,
                        listen: false)
                    .handleAddBirthdayBtnPressed(
                        context, dateOfDay, storageService);
              },
              child: Icon(Icons.add)),
        );
      },
    );
  }
}
