import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserNotificationStatusEvent {
  UserNotificationStatusEvent(
      {required this.userBirthday,
      required this.hasNotification,
      required this.notificationMsg});

  final UserBirthday userBirthday;
  final bool hasNotification;
  final String notificationMsg;
}

class UserNotificationStatusBloc
    extends Bloc<UserNotificationStatusEvent, bool> {
  UserNotificationStatusBloc(StorageService storageService,
      NotificationService notificationService, bool initialNotificationStatus)
      : super(initialNotificationStatus) {
    on<UserNotificationStatusEvent>((event, emit) async {
      final bool targetNotificationStatus = !event.hasNotification;
      final UserBirthday birthday = event.userBirthday;

      if (targetNotificationStatus) {
        // Persist initial 'true' status first
        birthday.hasNotification = true;
        await storageService.updateNotificationStatusForBirthday(
            birthday, true);

        try {
          await notificationService.scheduleNotificationForBirthday(
              birthday, event.notificationMsg);
          emit(true);
        } catch (e) {
          debugPrint("Failed to schedule notification: $e");
          // Revert and persist if scheduling failed
          birthday.hasNotification = false;
          await storageService.updateNotificationStatusForBirthday(
              birthday, false);
          emit(false);
        }
      } else {
        // Turning off: persist first, then cancel
        birthday.hasNotification = false;
        await storageService.updateNotificationStatusForBirthday(
            birthday, false);
        await notificationService.cancelNotificationForBirthday(birthday);
        emit(false);
      }
    });
  }
}
