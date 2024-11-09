import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
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
  UserNotificationStatusBloc(
      StorageService storageService, NotificationService notificationService)
      : super(false) {
    on<UserNotificationStatusEvent>((event, emit) async {
      bool notificationStatus = event.hasNotification;
      notificationStatus = !notificationStatus;
      UserBirthday birthday = event.userBirthday;
      birthday.hasNotification = notificationStatus;
      storageService.updateNotificationStatusForBirthday(
          birthday, notificationStatus);
      if (!notificationStatus) {
        notificationService.cancelNotificationForBirthday(birthday);
      } else {
        notificationService.scheduleNotificationForBirthday(
            birthday, event.notificationMsg);
      }
      emit(notificationStatus);
    });
  }
}
