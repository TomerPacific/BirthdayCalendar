import 'dart:async';
import 'dart:convert';
import 'package:birthday_calendar/service/notification_service/notificationCallbacks.dart';
import 'package:birthday_calendar/utils.dart';
import 'package:flutter/cupertino.dart';

import 'notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:birthday_calendar/constants.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/l10n/app_localizations.dart';

const String channel_id = "123";
const String channel_name = "birthday_notification";
const String navigationActionId = 'id_1';

class NotificationServiceImpl extends NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();
  List<NotificationCallbacks> selectNotificationStreamListeners = [];

  void init(BuildContext context) {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    _initializeLocalNotificationsPlugin(initializationSettings, context);

    selectNotificationStream.stream.listen((notificationEvent) {
      _rescheduleNotificationFromPayload(notificationEvent, context);
      selectNotificationStreamListeners.forEach((notificationListener) {
        notificationListener.onNotificationSelected(notificationEvent);
      });
    });

    tz.initializeTimeZones();
  }

  void _initializeLocalNotificationsPlugin(
      InitializationSettings initializationSettings,
      BuildContext context) async {
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) {
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
    });
    _handleApplicationWasLaunchedFromNotification(context);
  }

  void _showNotification(
      UserBirthday userBirthday, String notificationMessage) async {
    await flutterLocalNotificationsPlugin.show(
        userBirthday.hashCode,
        applicationName,
        notificationMessage,
        NotificationDetails(android: _createAndroidNotificationDetails()),
        payload: jsonEncode(userBirthday));
  }

  void scheduleNotificationForBirthday(
      UserBirthday userBirthday, String notificationMessage) async {
    DateTime now = DateTime.now();
    DateTime birthdayDate = userBirthday.birthdayDate;
    DateTime correctedBirthdayDate = birthdayDate;

    if (birthdayDate.year < now.year) {
      correctedBirthdayDate =
          new DateTime(now.year, birthdayDate.month, birthdayDate.day);
    }

    Duration difference = now.isAfter(correctedBirthdayDate)
        ? now.difference(correctedBirthdayDate)
        : correctedBirthdayDate.difference(now);

    bool didApplicationLaunchFromNotification =
        await _wasApplicationLaunchedFromNotification();
    if (didApplicationLaunchFromNotification && difference.inDays == 0) {
      _scheduleNotificationForNextYear(userBirthday, notificationMessage);
      return;
    } else if (!didApplicationLaunchFromNotification &&
        difference.inDays == 0) {
      _showNotification(userBirthday, notificationMessage);
      return;
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
        userBirthday.hashCode,
        applicationName,
        notificationMessage,
        tz.TZDateTime.now(tz.local).add(difference),
        NotificationDetails(android: _createAndroidNotificationDetails()),
        payload: jsonEncode(userBirthday),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  void _scheduleNotificationForNextYear(
      UserBirthday userBirthday, String notificationMessage) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        userBirthday.hashCode,
        applicationName,
        notificationMessage,
        tz.TZDateTime.now(tz.local).add(new Duration(days: 365)),
        NotificationDetails(android: _createAndroidNotificationDetails()),
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

  void _handleApplicationWasLaunchedFromNotification(
      BuildContext context) async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails != null &&
        notificationAppLaunchDetails.didNotificationLaunchApp) {
      NotificationResponse? notificationResponse =
          notificationAppLaunchDetails.notificationResponse;
      if (notificationResponse != null) {
        String? payload = notificationResponse.payload;
        selectNotificationStream.add(payload);
        _rescheduleNotificationFromPayload(payload, context);
      }
    }
  }

  Future<bool> _wasApplicationLaunchedFromNotification() async {
    NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails != null) {
      return notificationAppLaunchDetails.didNotificationLaunchApp;
    }

    return false;
  }

  void _rescheduleNotificationFromPayload(
      String? payload, BuildContext context) {
    UserBirthday? userBirthday = Utils.getUserBirthdayFromPayload(payload);
    if (userBirthday != null) {
      cancelNotificationForBirthday(userBirthday);
      scheduleNotificationForBirthday(
          userBirthday,
          AppLocalizations.of(context)!
              .notificationForBirthdayMessage(userBirthday.name));
    }
  }

  Future<List<PendingNotificationRequest>>
      getAllScheduledNotifications() async {
    List<PendingNotificationRequest> pendingNotifications =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return pendingNotifications;
  }

  @override
  void dispose() {
    selectNotificationStream.close();
    selectNotificationStreamListeners.clear();
  }

  @override
  void addListenerForSelectNotificationStream(NotificationCallbacks listener) {
    selectNotificationStreamListeners.add(listener);
  }

  @override
  void removeListenerForSelectNotificationStream(
      NotificationCallbacks listener) {
    if (selectNotificationStreamListeners.contains(listener)) {
      selectNotificationStreamListeners.remove(listener);
    }
  }

  AndroidNotificationDetails _createAndroidNotificationDetails() {
    return AndroidNotificationDetails(channel_id, channel_name,
        channelDescription: 'To remind you about upcoming birthdays',
        importance: Importance.max,
        priority: Priority.high,
        ticker: "ticker");
  }
}
