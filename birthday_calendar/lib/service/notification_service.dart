
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:birthday_calendar/constants.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService
      ._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  final AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('app_icon');

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  static const channel_id = "123";

  Future<void> init() async {
    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: null,
        macOS: null);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
    onSelectNotification: selectNotification);
    tz.initializeTimeZones();
  }

  Future selectNotification(String payload) async {

  }

  void sendAndroidNotification(String notificationMessage) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
        channel_id, applicationName, 'To remind you about upcoming birthdays',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false);
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'BirthdayCalendar', notificationMessage, platformChannelSpecifics,
        payload: 'birthdayData');
  }

 void scheduleNotificationForBirthday(UserBirthday userBirthday, String notificationMessage) async {

    DateTime now = DateTime.now();
    DateTime birthdayDate = userBirthday.birthdayDate;
    Duration difference = now.isAfter(birthdayDate) ? now.difference(birthdayDate) : birthdayDate.difference(now);

   await flutterLocalNotificationsPlugin.zonedSchedule(
       userBirthday.hashCode,
       applicationName,
       notificationMessage,
       tz.TZDateTime.now(tz.local).add(difference),
       const NotificationDetails(
           android: AndroidNotificationDetails(channel_id,
               applicationName, 'To remind you about upcoming birthdays')),
       androidAllowWhileIdle: true,
       uiLocalNotificationDateInterpretation:
       UILocalNotificationDateInterpretation.absoluteTime);
 }

 void cancelNotificationForBirthday(UserBirthday birthday) async {
    await flutterLocalNotificationsPlugin.cancel(birthday.hashCode);
 }

}