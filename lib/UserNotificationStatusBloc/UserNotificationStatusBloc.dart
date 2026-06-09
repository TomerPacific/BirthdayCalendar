import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/model/birthdays_update.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:collection/collection.dart';

class UserNotificationStatusEvent {
  UserNotificationStatusEvent(
      {required this.userBirthday,
      required this.hasNotification,
      required this.notificationMsg});

  final UserBirthday userBirthday;
  final bool hasNotification;
  final String notificationMsg;
}

class UserBirthdayBloc
    extends Bloc<UserNotificationStatusEvent, UserBirthday> {
  StreamSubscription<BirthdaysUpdate>? _storageSubscription;

  UserBirthdayBloc(StorageService storageService,
      NotificationService notificationService, UserBirthday birthday)
      : super(birthday) {
    
    _storageSubscription = storageService.getBirthdaysStream().listen((update) {
      if (update.date.month == state.birthdayDate.month &&
          update.date.day == state.birthdayDate.day) {
        UserBirthday? updatedBirthday = update.birthdays
            .firstWhereOrNull((element) => element.name == state.name);
        if (updatedBirthday != null && updatedBirthday != state) {
          emit(updatedBirthday);
        }
      }
    });

    on<UserNotificationStatusEvent>((event, emit) async {
      final bool targetNotificationStatus = !event.hasNotification;
      UserBirthday birthday = event.userBirthday;

      if (targetNotificationStatus) {
        // Persist initial 'true' status first
        birthday = birthday.copyWith(hasNotification: true);
        await storageService.updateNotificationStatusForBirthday(
            birthday, true);

        try {
          await notificationService.scheduleNotificationForBirthday(
              birthday, event.notificationMsg);
          emit(birthday);
        } catch (e) {
          debugPrint("Failed to schedule notification: $e");
          // Revert and persist if scheduling failed
          birthday = birthday.copyWith(hasNotification: false);
          await storageService.updateNotificationStatusForBirthday(
              birthday, false);
          emit(birthday);
        }
      } else {
        // Turning off: persist first, then cancel
        birthday = birthday.copyWith(hasNotification: false);
        await storageService.updateNotificationStatusForBirthday(
            birthday, false);

        try {
          await notificationService.cancelNotificationForBirthday(birthday);
          emit(birthday);
        } catch (e) {
          debugPrint("Failed to cancel notification: $e");
          // Revert and persist if cancellation failed
          birthday = birthday.copyWith(hasNotification: true);
          await storageService.updateNotificationStatusForBirthday(
              birthday, true);
          emit(birthday);
        }
      }
    });
  }

  @override
  Future<void> close() {
    _storageSubscription?.cancel();
    return super.close();
  }
}
