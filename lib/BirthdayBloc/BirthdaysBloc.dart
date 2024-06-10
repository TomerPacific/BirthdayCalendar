import 'package:birthday_calendar/BirthdayBloc/BirthdaysState.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum BirthdayEvent { AddBirthday, RemoveBirthday, ShowAddBirthdayDialog }

class BirthdaysEvent {
  final BirthdayEvent eventName;
  final UserBirthday? birthday;
  final bool? shouldShowAddBirthdayDialog;
  final List<UserBirthday> birthdays;
  final DateTime? date;

  BirthdaysEvent(
      {required this.eventName,
      this.birthday,
      this.shouldShowAddBirthdayDialog,
      required this.birthdays,
      this.date});
}

class BirthdaysBloc extends Bloc<BirthdaysEvent, BirthdaysState> {
  BirthdaysBloc(NotificationService notificationService,
      StorageService storageService, List<UserBirthday> birthdaysForDate)
      : super(BirthdaysState(
            date: DateTime.now(),
            birthdays: birthdaysForDate,
            showAddBirthdayDialog: false)) {
    on<BirthdaysEvent>((event, emit) {
      switch (event.eventName) {
        case BirthdayEvent.AddBirthday:
          _handleAddEvent(event, emit, storageService, notificationService);
          break;
        case BirthdayEvent.RemoveBirthday:
          _handleRemoveEvent(event, emit, storageService, notificationService);
          break;
        case BirthdayEvent.ShowAddBirthdayDialog:
          emit(new BirthdaysState(showAddBirthdayDialog: true));
          break;
      }
    });
  }

  void _handleAddEvent(BirthdaysEvent event, Emitter emit,
      StorageService storageService, NotificationService notificationService) {
    List<UserBirthday> currentBirthdays = event.birthdays;
    UserBirthday? userBirthday = event.birthday;

    if (userBirthday == null) {
      return;
    }

    currentBirthdays.add(userBirthday);

    DateTime birthdayDate = userBirthday.birthdayDate;
    List<UserBirthday> birthdaysMatchingDate = currentBirthdays
        .where((element) => element.birthdayDate == birthdayDate)
        .toList();
    storageService.saveBirthdaysForDate(birthdayDate, birthdaysMatchingDate);
    notificationService.scheduleNotificationForBirthday(
        userBirthday, "${userBirthday.name} has an upcoming birthday!");
    emit(new BirthdaysState(
        date: birthdayDate, birthdays: currentBirthdays, showAddBirthdayDialog: false));
  }

  void _handleRemoveEvent(
      BirthdaysEvent event,
      Emitter emit,
      StorageService storageService,
      NotificationService notificationService) async {
    List<UserBirthday> currentBirthdays = event.birthdays;

    UserBirthday? userBirthday = event.birthday;

    if (userBirthday == null) {
      return;
    }

    DateTime birthdayDate = userBirthday.birthdayDate;
    currentBirthdays.remove(event.birthday);

    List<UserBirthday> birthdaysForDateDeleted =
        await storageService.getBirthdaysForDate(birthdayDate, false);

    List<UserBirthday> filteredBirthdays = birthdaysForDateDeleted
        .where((element) => !element.equals(userBirthday))
        .toList();

    storageService.saveBirthdaysForDate(birthdayDate, filteredBirthdays);
    emit(new BirthdaysState(
        date: birthdayDate, birthdays: currentBirthdays, showAddBirthdayDialog: false));
  }
}
