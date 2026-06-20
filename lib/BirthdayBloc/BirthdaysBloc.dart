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
  final List<UserBirthday>? birthdays;
  final DateTime? date;
  final String? notificationMsg;

  BirthdaysEvent(
      {required this.eventName,
      this.birthday,
      this.shouldShowAddBirthdayDialog,
      this.birthdays,
      this.date,
      this.notificationMsg});
}

class BirthdaysBloc extends Bloc<BirthdaysEvent, BirthdaysState> {
  BirthdaysBloc(NotificationService notificationService,
      StorageService storageService, List<UserBirthday> birthdaysForDate)
      : super(BirthdaysLoaded(
            date: DateTime.now(),
            birthdays: birthdaysForDate)) {
    on<BirthdaysEvent>((event, emit) async {
      switch (event.eventName) {
        case BirthdayEvent.AddBirthday:
          await _handleAddEvent(event, emit, storageService, notificationService);
          break;
        case BirthdayEvent.RemoveBirthday:
          await _handleRemoveEvent(
              event, emit, storageService, notificationService);
          break;
        case BirthdayEvent.ShowAddBirthdayDialog:
          emit(BirthdaysShowDialog());
          break;
      }
    });
  }

  Future<void> _handleAddEvent(
      BirthdaysEvent event,
      Emitter<BirthdaysState> emit,
      StorageService storageService,
      NotificationService notificationService) async {
    UserBirthday? userBirthday = event.birthday;

    if (userBirthday == null) {
      return;
    }

    DateTime birthdayDate = userBirthday.birthdayDate;
    List<UserBirthday> birthdaysMatchingDate = await storageService
        .getBirthdaysForDate(userBirthday.birthdayDate, false);
    birthdaysMatchingDate.add(userBirthday);
    await storageService.saveBirthdaysForDate(birthdayDate, birthdaysMatchingDate);

    String notificationMsg = event.notificationMsg ?? "";
    await notificationService.scheduleNotificationForBirthday(
        userBirthday, notificationMsg);

    emit(BirthdaysLoaded(
        date: birthdayDate,
        birthdays: birthdaysMatchingDate));
  }

  Future<void> _handleRemoveEvent(
      BirthdaysEvent event,
      Emitter<BirthdaysState> emit,
      StorageService storageService,
      NotificationService notificationService) async {
    UserBirthday? userBirthday = event.birthday;

    if (userBirthday == null) {
      return;
    }

    DateTime birthdayDate = userBirthday.birthdayDate;

    List<UserBirthday> birthdaysForDateDeleted =
        await storageService.getBirthdaysForDate(birthdayDate, false);

    List<UserBirthday> filteredBirthdays = birthdaysForDateDeleted
        .where((element) => element != userBirthday)
        .toList();

    await storageService.saveBirthdaysForDate(birthdayDate, filteredBirthdays);
    await notificationService.cancelNotificationForBirthday(userBirthday);
    emit(BirthdaysLoaded(
        date: birthdayDate,
        birthdays: filteredBirthdays));
  }
}
