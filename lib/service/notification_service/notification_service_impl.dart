import 'dart:async';
import 'dart:convert';
import 'package:birthday_calendar/utils.dart';

import 'notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:birthday_calendar/constants.dart';
import 'package:birthday_calendar/model/user_birthday.dart';

const String channel_id = "123";
const String navigationActionId = 'id_3';

class NotificationServiceImpl extends NotificationService {

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final StreamController<String?> selectNotificationStream =
  StreamController<String?>.broadcast();

  void init(void Function(StreamController<String?>) subscribeToNotificationStream) {

    final AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');

    final InitializationSettings initializationSettings =
    InitializationSettings(
        android: initializationSettingsAndroid);

    subscribeToNotificationStream(selectNotificationStream);

    initializeLocalNotificationsPlugin(initializationSettings);

    tz.initializeTimeZones();
  }

  void initializeLocalNotificationsPlugin(InitializationSettings initializationSettings) async {
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
          switch (notificationResponse.notificationResponseType) {
            case NotificationResponseType.selectedNotification:
              selectNotificationStream.add(notificationResponse.payload);
              break;
            case NotificationResponseType.selectedNotificationAction:
              if (notificationResponse.actionId == navigationActionId) {
                selectNotificationStream.add(notificationResponse.payload);
              }
              break;
          }
        }
    );
    handleApplicationWasLaunchedFromNotification("");
  }

  Future selectNotification(String? payload) async {
    UserBirthday userBirthday = Utils.getUserBirthdayFromPayload(payload ?? '');
    cancelNotificationForBirthday(userBirthday);
    scheduleNotificationForBirthday(userBirthday, "${userBirthday.name} has an upcoming birthday!");
  }

  void showNotification(UserBirthday userBirthday, String notificationMessage) async {
    await flutterLocalNotificationsPlugin.show(
        userBirthday.hashCode,
        applicationName,
        notificationMessage,
        const NotificationDetails(
            android: AndroidNotificationDetails(
                channel_id,
                applicationName,
                channelDescription: 'To remind you about upcoming birthdays')
        ),
        payload: jsonEncode(userBirthday)
    );
  }

  void scheduleNotificationForBirthday(UserBirthday userBirthday, String notificationMessage) async {
    DateTime now = DateTime.now();
    DateTime birthdayDate = userBirthday.birthdayDate;
    DateTime correctedBirthdayDate = birthdayDate;

    if (birthdayDate.year < now.year) {
      correctedBirthdayDate = new DateTime(now.year, birthdayDate.month, birthdayDate.day);
    }

    Duration difference = now.isAfter(correctedBirthdayDate)
        ? now.difference(correctedBirthdayDate)
        : correctedBirthdayDate.difference(now);

    bool didApplicationLaunchFromNotification = await _wasApplicationLaunchedFromNotification();
    if (didApplicationLaunchFromNotification && difference.inDays == 0) {
      scheduleNotificationForNextYear(userBirthday, notificationMessage);
      return;
    } else if (!didApplicationLaunchFromNotification && difference.inDays == 0) {
      showNotification(userBirthday, notificationMessage);
      return;
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
        userBirthday.hashCode,
        applicationName,
        notificationMessage,
        tz.TZDateTime.now(tz.local).add(difference),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                channel_id,
                applicationName,
                channelDescription: 'To remind you about upcoming birthdays')
        ),
        payload: jsonEncode(userBirthday),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
  }

  void scheduleNotificationForNextYear(UserBirthday userBirthday, String notificationMessage) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        userBirthday.hashCode,
        applicationName,
        notificationMessage,
        tz.TZDateTime.now(tz.local).add(new Duration(days: 365)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                channel_id,
                applicationName,
                channelDescription: 'To remind you about upcoming birthdays')
        ),
        payload: jsonEncode(userBirthday),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
  }

  void cancelNotificationForBirthday(UserBirthday birthday) async {
    await flutterLocalNotificationsPlugin.cancel(birthday.hashCode);
  }

  void cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  void handleApplicationWasLaunchedFromNotification(String payload) async {

    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
    await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails != null && notificationAppLaunchDetails.didNotificationLaunchApp) {
      _rescheduleNotificationFromPayload(notificationAppLaunchDetails.notificationResponse != null ?
      notificationAppLaunchDetails.notificationResponse.toString() :
      "");
    }
  }

  Future<bool> _wasApplicationLaunchedFromNotification() async {
    NotificationAppLaunchDetails? notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails != null) {
      return notificationAppLaunchDetails.didNotificationLaunchApp;
    }

    return false;
  }

  void _rescheduleNotificationFromPayload(String payload) {
    UserBirthday userBirthday = Utils.getUserBirthdayFromPayload(payload);
    cancelNotificationForBirthday(userBirthday);
    scheduleNotificationForBirthday(userBirthday, "${userBirthday.name} has an upcoming birthday!");
  }

  Future<List<PendingNotificationRequest>> getAllScheduledNotifications() async {
    List<PendingNotificationRequest> pendingNotifications = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return pendingNotifications;
  }

  @override
  void dispose() {
    selectNotificationStream.close();
  }
  
}
