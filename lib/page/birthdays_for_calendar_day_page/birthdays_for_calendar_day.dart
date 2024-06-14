import 'package:birthday_calendar/BirthdayBloc/BirthdaysBloc.dart';
import 'package:birthday_calendar/BirthdayBloc/BirthdaysState.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:birthday_calendar/widget/add_birthday_form.dart';
import 'package:flutter/material.dart';
import 'package:birthday_calendar/page/birthday/birthday.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/service/date_service/date_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return BlocProvider(
        create: (context) =>
            BirthdaysBloc(notificationService, storageService, birthdays),
        child: BlocBuilder<BirthdaysBloc, BirthdaysState>(
            builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
                title: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text(
                        "Birthdays for ${dateService.convertMonthToWord(this.dateOfDay.month)} ${this.dateOfDay.day}"))),
            body: Center(
                child: Column(
              children: [
                (state.birthdays == null || state.birthdays!.length == 0)
                    ? Spacer()
                    : Expanded(
                        child: ListView.builder(
                          itemCount: state.birthdays != null
                              ? state.birthdays!.length
                              : 0,
                          itemBuilder: (BuildContext context, int index) {
                            return BirthdayWidget(
                                key: Key(state.birthdays![index].name),
                                birthdayOfPerson: state.birthdays![index],
                                onDeletePressedCallback: () {
                                  BlocProvider.of<BirthdaysBloc>(context).add(
                                      new BirthdaysEvent(
                                          eventName:
                                              BirthdayEvent.RemoveBirthday,
                                          birthday: state.birthdays![index],
                                          birthdays: birthdays));
                                },
                                indexOfBirthday: index,
                                storageService: storageService,
                                notificationService: notificationService);
                          },
                        ),
                      ),
                BlocListener<BirthdaysBloc, BirthdaysState>(
                  listener: (context, state) {
                    if (state.showAddBirthdayDialog) {
                      showDialog(
                          context: context,
                          builder: (_) => BlocProvider.value(
                              value: BlocProvider.of<BirthdaysBloc>(context),
                              child: AddBirthdayForm(
                                  dateOfDay: dateOfDay,
                                  storageService: storageService)));
                    }
                  },
                  child: Spacer(),
                )
              ],
            )),
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                  BlocProvider.of<BirthdaysBloc>(context).add(BirthdaysEvent(
                      eventName: BirthdayEvent.ShowAddBirthdayDialog,
                      shouldShowAddBirthdayDialog: true,
                      birthdays: birthdays));
                },
                child: Icon(Icons.add)),
          );
        }));
  }
}
