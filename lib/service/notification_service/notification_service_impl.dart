import 'dart:convert';
import 'dart:io' show Platform;

import 'notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:birthday_calendar/constants.dart';
import 'package:birthday_calendar/model/user_birthday.dart';

const String channel_id = "123";

class NotificationServiceImpl extends NotificationService {

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void init(Future<dynamic> Function(int, String?, String?, String?)? onDidReceive) {
    final AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');

    final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(onDidReceiveLocalNotification: onDidReceive);

    final InitializationSettings initializationSettings =
    InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS, macOS: null);

    initializeLocalNotificationsPlugin(initializationSettings);

    tz.initializeTimeZones();
  }

  void initializeLocalNotificationsPlugin(InitializationSettings initializationSettings) async {
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
    handleApplicationWasLaunchedFromNotification("");
  }

  Future selectNotification(String? payload) async {
    UserBirthday userBirthday = getUserBirthdayFromPayload(payload ?? '');
    cancelNotificationForBirthday(userBirthday);
    scheduleNotificationForBirthday(userBirthday, "${userBirthday.name} has an upcoming birthday!");
  }

  void showNotification(UserBirthday userBirthday, String notificationMessage) async {
    await flutterLocalNotificationsPlugin.show(
        userBirthday.hashCode,
        applicationName,
        notificationMessage,
        const NotificationDetails(
            android: AndroidNotificationDetails(channel_id, applicationName,
                'To remind you about upcoming birthdays')
        ),
        payload: jsonEncode(userBirthday)
    );
  }

  void scheduleNotificationForBirthday(UserBirthday userBirthday, String notificationMessage) async {
    DateTime now = DateTime.now();
    DateTime birthdayDate = userBirthday.birthdayDate;
    Duration difference = now.isAfter(birthdayDate)
        ? now.difference(birthdayDate)
        : birthdayDate.difference(now);

    _wasApplicationLaunchedFromNotification()
        .then((bool didApplicationLaunchFromNotification) => {
      if (didApplicationLaunchFromNotification && difference.inDays == 0) {
          scheduleNotificationForNextYear(userBirthday, notificationMessage)}
      else if (!didApplicationLaunchFromNotification && difference.inDays == 0) {
          showNotification(userBirthday, notificationMessage)}
        });

    await flutterLocalNotificationsPlugin.zonedSchedule(
        userBirthday.hashCode,
        applicationName,
        notificationMessage,
        tz.TZDateTime.now(tz.local).add(difference),
        const NotificationDetails(
            android: AndroidNotificationDetails(channel_id, applicationName,
                'To remind you about upcoming birthdays')),
        payload: jsonEncode(userBirthday),
        androidAllowWhileIdle: true,
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
            android: AndroidNotificationDetails(channel_id, applicationName,
                'To remind you about upcoming birthdays')),
        payload: jsonEncode(userBirthday),
        androidAllowWhileIdle: true,
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
    if (Platform.isIOS) {
      _rescheduleNotificationFromPayload(payload);
      return;
    }

    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
    await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails != null && notificationAppLaunchDetails.didNotificationLaunchApp) {
      _rescheduleNotificationFromPayload(notificationAppLaunchDetails.payload ?? "");
    }
  }

  UserBirthday getUserBirthdayFromPayload(String payload) {
    Map<String, dynamic> json = jsonDecode(payload);
    UserBirthday userBirthday = UserBirthday.fromJson(json);
    return userBirthday;
  }

  Future<bool> _wasApplicationLaunchedFromNotification() async {
    NotificationAppLaunchDetails? notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails != null) {
      return notificationAppLaunchDetails.didNotificationLaunchApp;
    }

    return false;
  }

  void _rescheduleNotificationFromPayload(String payload) {
    UserBirthday userBirthday = getUserBirthdayFromPayload(payload);
    cancelNotificationForBirthday(userBirthday);
    scheduleNotificationForBirthday(userBirthday, "${userBirthday.name} has an upcoming birthday!");
  }
}
