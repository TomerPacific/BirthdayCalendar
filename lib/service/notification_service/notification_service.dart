import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract class NotificationService {
  void init(Future<dynamic> Function(int, String?, String?, String?)? onDidReceive);
  Future selectNotification(String? payload);
  void showNotification(UserBirthday userBirthday, String notificationMessage);
  void scheduleNotificationForBirthday(UserBirthday userBirthday, String notificationMessage);
  void scheduleNotificationForNextYear(UserBirthday userBirthday, String notificationMessage);
  void cancelNotificationForBirthday(UserBirthday birthday);
  void cancelAllNotifications();
  void handleApplicationWasLaunchedFromNotification(String payload);
  UserBirthday getUserBirthdayFromPayload(String payload);
  Future<List<PendingNotificationRequest>> getAllScheduledNotifications();
}