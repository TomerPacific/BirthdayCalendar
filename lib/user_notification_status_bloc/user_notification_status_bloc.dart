import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UserNotificationStatusEvent {}

class UserNotificationStatusToggled extends UserNotificationStatusEvent {
  UserNotificationStatusToggled(
      {required this.userBirthday, required this.notificationMsg});

  final UserBirthday userBirthday;
  final String notificationMsg;
}

sealed class UserNotificationStatusState {
  final bool hasNotification;
  UserNotificationStatusState(this.hasNotification);
}

class UserNotificationStatusInitial extends UserNotificationStatusState {
  UserNotificationStatusInitial(super.hasNotification);
}

class UserNotificationStatusChanged extends UserNotificationStatusState {
  UserNotificationStatusChanged(super.hasNotification);
}

class UserNotificationStatusBloc
    extends Bloc<UserNotificationStatusEvent, UserNotificationStatusState> {
  final StorageService storageService;
  final NotificationService notificationService;

  UserNotificationStatusBloc(
      this.storageService, this.notificationService, bool initialStatus)
      : super(UserNotificationStatusInitial(initialStatus)) {
    on<UserNotificationStatusToggled>((event, emit) async {
      bool newStatus = !state.hasNotification;
      UserBirthday birthday = event.userBirthday;
      birthday.hasNotification = newStatus;
      await storageService.updateNotificationStatusForBirthday(
          birthday, newStatus);
      if (!newStatus) {
        await notificationService.cancelNotificationForBirthday(birthday);
      } else {
        await notificationService.scheduleNotificationForBirthday(
            birthday, event.notificationMsg);
      }
      emit(UserNotificationStatusChanged(newStatus));
    });
  }
}
