import 'dart:async';

import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/service/notification_service/notificationCallbacks.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract class NotificationService {
  Future<void> init(BuildContext context);

  Future<bool> isNotificationPermissionGranted();

  Future<bool> requestNotificationPermission(BuildContext context);

  void scheduleNotificationForBirthday(
      UserBirthday userBirthday, String notificationMessage);

  void cancelNotificationForBirthday(UserBirthday birthday);

  void cancelAllNotifications();

  Future<List<PendingNotificationRequest>> getAllScheduledNotifications();

  void dispose();

  void addListenerForSelectNotificationStream(NotificationCallbacks listener);

  void removeListenerForSelectNotificationStream(
      NotificationCallbacks listener);
}
