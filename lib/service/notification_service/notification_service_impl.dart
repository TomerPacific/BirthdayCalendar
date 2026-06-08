import 'dart:async';
import 'dart:convert';
import 'package:birthday_calendar/service/notification_service/notificationCallbacks.dart';
import 'package:birthday_calendar/service/permission_service/permissions_service.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:birthday_calendar/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

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
  NotificationServiceImpl({
    required this.permissionsService,
    required this.storageService,
  });

  StreamSubscription<String?>? _selectSubscription;

  final PermissionsService permissionsService;
  final StorageService storageService;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();
  List<NotificationCallbacks> selectNotificationStreamListeners = [];

  Future<void> init(BuildContext context) async {
    tz.initializeTimeZones();

    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _initializeLocalNotificationsPlugin(initializationSettings, context);

    AndroidFlutterLocalNotificationsPlugin?
        androidFlutterLocalNotificationsPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final channel = AndroidNotificationChannel(
      channel_id,
      channel_name,
      description: 'To remind you about upcoming birthdays',
      importance: Importance.max,
    );
    await androidFlutterLocalNotificationsPlugin
        ?.createNotificationChannel(channel);

    bool permissionGranted = await isNotificationPermissionGranted(context);
    if (permissionGranted) {
      await _setupSubscription(context);
    }
  }

  Future<bool> isNotificationPermissionGranted(BuildContext context) async {
    PermissionStatus permissionStatus = await permissionsService
        .getPermissionStatus(notificationsPermissionKey);

    if (permissionStatus.isGranted) {
      await storageService
          .setNotificationPermissionState(NotificationPermissionState.granted);
      return true;
    }

    if (permissionStatus.isPermanentlyDenied) {
      await storageService.setNotificationPermissionState(
          NotificationPermissionState.deniedPermanently);
      return false;
    }

    await storageService.setNotificationPermissionState(
        NotificationPermissionState.deniedTemporary);
    return false;
  }

  Future<PermissionStatus> requestNotificationPermission(
      BuildContext context) async {
    PermissionStatus notificationPermissionStatus = await permissionsService
        .getPermissionStatus(notificationsPermissionKey);

    if (notificationPermissionStatus.isGranted) {
      await storageService
          .setNotificationPermissionState(NotificationPermissionState.granted);
      return PermissionStatus.granted;
    }

    notificationPermissionStatus = await permissionsService
        .requestPermissionAndGetStatus(notificationsPermissionKey);

    if (notificationPermissionStatus.isGranted) {
      await storageService
          .setNotificationPermissionState(NotificationPermissionState.granted);
      await _setupSubscription(context);
    } else if (notificationPermissionStatus.isPermanentlyDenied) {
      await storageService.setNotificationPermissionState(
          NotificationPermissionState.deniedPermanently);
    } else {
      await storageService.setNotificationPermissionState(
          NotificationPermissionState.deniedTemporary);
    }

    return notificationPermissionStatus;
  }

  Future<void> _initializeLocalNotificationsPlugin(
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
    await _handleApplicationWasLaunchedFromNotification(context);
  }

  Future<void> _showNotification(
      UserBirthday userBirthday, String notificationMessage) async {
    await flutterLocalNotificationsPlugin.show(
        userBirthday.notificationId,
        applicationName,
        notificationMessage,
        NotificationDetails(android: _createAndroidNotificationDetails()),
        payload: jsonEncode(userBirthday));
  }

  Future<void> scheduleNotificationForBirthday(
      UserBirthday userBirthday, String notificationMessage) async {
    DateTime now = DateTime.now();
    DateTime birthdayDate = userBirthday.birthdayDate;

    DateTime nextBirthdayOccurrence =
        _getNextOccurrence(birthdayDate.month, birthdayDate.day, now);

    Duration difference = nextBirthdayOccurrence.difference(now);

    bool didApplicationLaunchFromNotification =
        await _wasApplicationLaunchedFromNotification();
    if (didApplicationLaunchFromNotification && difference.inDays == 0) {
      await _scheduleNotificationForNextYear(userBirthday, notificationMessage);
      return;
    } else if (!didApplicationLaunchFromNotification &&
        difference.inDays == 0) {
      await _showNotification(userBirthday, notificationMessage);
      return;
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
        userBirthday.notificationId,
        applicationName,
        notificationMessage,
        tz.TZDateTime.from(nextBirthdayOccurrence, tz.local),
        NotificationDetails(android: _createAndroidNotificationDetails()),
        payload: jsonEncode(userBirthday),
        androidScheduleMode: await _getSafeScheduleMode());
  }

  DateTime _getNextOccurrence(int month, int day, DateTime now) {
    // Start with the birthday in the current year
    int year = now.year;

    // Handle Feb 29
    if (month == 2 && day == 29 && !_isLeapYear(year)) {
      // If not a leap year, reminders for Feb 29 usually fall on Feb 28 or March 1.
      // Here we shift to March 1st.
      month = 3;
      day = 1;
    }

    DateTime occurrence = DateTime(year, month, day);

    // If it already happened today or earlier this year, move to next year
    if (occurrence.isBefore(now)) {
      year++;
      if (month == 2 && day == 29 && !_isLeapYear(year)) {
        month = 3;
        day = 1;
      }
      occurrence = DateTime(year, month, day);
    }

    return occurrence;
  }

  bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  Future<void> _scheduleNotificationForNextYear(
      UserBirthday userBirthday, String notificationMessage) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        userBirthday.notificationId,
        applicationName,
        notificationMessage,
        tz.TZDateTime.now(tz.local).add(new Duration(days: 365)),
        NotificationDetails(android: _createAndroidNotificationDetails()),
        payload: jsonEncode(userBirthday),
        androidScheduleMode: await _getSafeScheduleMode());
  }

  Future<AndroidScheduleMode> _getSafeScheduleMode() async {
    PermissionStatus status = await Permission.scheduleExactAlarm.status;
    if (status.isGranted) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  Future<void> cancelNotificationForBirthday(UserBirthday birthday) async {
    await flutterLocalNotificationsPlugin.cancel(birthday.notificationId);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> _handleApplicationWasLaunchedFromNotification(
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
        await _rescheduleNotificationFromPayload(payload, context);
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

  Future<void> _rescheduleNotificationFromPayload(
      String? payload, BuildContext context) async {
    UserBirthday? userBirthday = Utils.getUserBirthdayFromPayload(payload);
    if (userBirthday != null) {
      await cancelNotificationForBirthday(userBirthday);
      await scheduleNotificationForBirthday(
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
    _selectSubscription?.cancel();
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

  Future<void> _setupSubscription(BuildContext context) async {
    await _selectSubscription?.cancel();
    _selectSubscription = selectNotificationStream.stream.listen((payload) async {
      await _rescheduleNotificationFromPayload(payload, context);
      for (var listener in selectNotificationStreamListeners) {
        listener.onNotificationSelected(payload);
      }
    });
  }
}
