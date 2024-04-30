import 'dart:async';

import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/service/notification_service/notificationCallbacks.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract class NotificationService {
  void init();
  Future selectNotification(String? payload);
  void showNotification(UserBirthday userBirthday, String notificationMessage);
  void scheduleNotificationForBirthday(UserBirthday userBirthday, String notificationMessage);
  void scheduleNotificationForNextYear(UserBirthday userBirthday, String notificationMessage);
  void cancelNotificationForBirthday(UserBirthday birthday);
  void cancelAllNotifications();
  void handleApplicationWasLaunchedFromNotification(String payload);
  Future<List<PendingNotificationRequest>> getAllScheduledNotifications();
  void dispose();
  void addListenerForSelectNotificationStream(NotificationCallbacks listener);
  void removeListenerForSelectNotificationStream(NotificationCallbacks listener);
}