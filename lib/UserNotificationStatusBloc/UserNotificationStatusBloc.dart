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
      bool targetNotificationStatus = !event.hasNotification;
      UserBirthday birthday = event.userBirthday;

      bool finalStatus = targetNotificationStatus;
      if (targetNotificationStatus) {
        try {
          await notificationService.scheduleNotificationForBirthday(
              birthday, event.notificationMsg);
        } catch (e) {
          debugPrint("Failed to schedule notification: $e");
          finalStatus = false;
        }
      } else {
        await notificationService.cancelNotificationForBirthday(birthday);
      }

      birthday.hasNotification = finalStatus;
      await storageService.updateNotificationStatusForBirthday(
          birthday, finalStatus);
      emit(finalStatus);
    });
  }
}
