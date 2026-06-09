import 'package:birthday_calendar/BirthdayBloc/BirthdaysState.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/model/birthdays_update.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

enum BirthdayEvent { AddBirthday, RemoveBirthday, ShowAddBirthdayDialog, BirthdaysUpdated }

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
  StreamSubscription<BirthdaysUpdate>? _storageSubscription;

  BirthdaysBloc(
      NotificationService notificationService,
      StorageService storageService,
      DateTime date,
      List<UserBirthday> birthdaysForDate)
      : super(BirthdaysState(
            date: date,
            birthdays: birthdaysForDate,
            showAddBirthdayDialog: false)) {
    
    _storageSubscription = storageService.getBirthdaysStream().listen((update) {
      if (update.date.month == date.month && update.date.day == date.day) {
        add(BirthdaysEvent(
            eventName: BirthdayEvent.BirthdaysUpdated,
            birthdays: update.birthdays));
      }
    });

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
          emit(new BirthdaysState(
              date: state.date,
              birthdays: state.birthdays,
              showAddBirthdayDialog: true));
          break;
        case BirthdayEvent.BirthdaysUpdated:
          emit(new BirthdaysState(
              date: state.date,
              birthdays: event.birthdays,
              showAddBirthdayDialog: false));
          break;
      }
    });
  }

  @override
  Future<void> close() {
    _storageSubscription?.cancel();
    return super.close();
  }

  Future<void> _handleAddEvent(
      BirthdaysEvent event,
      Emitter emit,
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
    await storageService.saveBirthdaysForDate(
        birthdayDate, birthdaysMatchingDate);

    if (userBirthday.hasNotification) {
      String notificationMsg = event.notificationMsg ?? "";
      try {
        await notificationService.scheduleNotificationForBirthday(
            userBirthday, notificationMsg);
      } catch (e) {
        debugPrint("Failed to schedule notification: $e");
        UserBirthday updatedBirthday =
            userBirthday.copyWith(hasNotification: false);
        int index = birthdaysMatchingDate.indexOf(userBirthday);
        if (index != -1) {
          birthdaysMatchingDate[index] = updatedBirthday;
        }
        await storageService.saveBirthdaysForDate(
            birthdayDate, birthdaysMatchingDate);
        userBirthday = updatedBirthday;
      }
    }

    emit(new BirthdaysState(
        date: birthdayDate,
        birthdays: birthdaysMatchingDate,
        showAddBirthdayDialog: false));
  }

  Future<void> _handleRemoveEvent(
      BirthdaysEvent event,
      Emitter emit,
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
    emit(new BirthdaysState(
        date: birthdayDate,
        birthdays: filteredBirthdays,
        showAddBirthdayDialog: false));
  }
}
