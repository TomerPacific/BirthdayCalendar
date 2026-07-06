import 'dart:async';

import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/service/notification_service/notification_callbacks.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class NotificationService {
  Future<void> init(String Function(String name) notificationMessageProvider);

  Future<bool> isNotificationPermissionGranted();

  Future<PermissionStatus> getNotificationPermissionStatus();

  Future<PermissionStatus> requestNotificationPermission();

  Future<bool> shouldShowNotificationRationale();

  Future<void> scheduleNotificationForBirthday(
      UserBirthday userBirthday, String notificationMessage);

  Future<void> cancelNotificationForBirthday(UserBirthday birthday);

  Future<void> cancelAllNotifications();

  Future<List<PendingNotificationRequest>> getAllScheduledNotifications();

  void dispose();

  void addListenerForSelectNotificationStream(NotificationCallbacks listener);

  void removeListenerForSelectNotificationStream(
      NotificationCallbacks listener);
}
