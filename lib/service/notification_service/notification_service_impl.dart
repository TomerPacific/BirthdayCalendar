import 'dart:async';
import 'dart:convert';
import 'package:birthday_calendar/service/notification_service/notificationCallbacks.dart';
import 'package:birthday_calendar/service/permission_service/permissions_service.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:birthday_calendar/utils.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:birthday_calendar/constants.dart';
import 'package:birthday_calendar/model/user_birthday.dart';

const String channel_id = "123";
const String channel_name = "birthday_notification";
const String navigationActionId = 'id_1';

class NotificationServiceImpl extends NotificationService {
  NotificationServiceImpl({
    required this.permissionsService,
    required this.storageService,
  });

  StreamSubscription<String?>? _selectSubscription;
  String Function(String name)? _notificationMessageProvider;

  final PermissionsService permissionsService;
  final StorageService storageService;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();
  List<NotificationCallbacks> selectNotificationStreamListeners = [];

  @override
  Future<void> init(String Function(String name) notificationMessageProvider) async {
    _notificationMessageProvider = notificationMessageProvider;
    tz.initializeTimeZones();

    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _initializeLocalNotificationsPlugin(initializationSettings);

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

    bool permissionGranted = await isNotificationPermissionGranted();
    if (permissionGranted) {
      await _setupSubscription();
    }
  }

  @override
  Future<bool> isNotificationPermissionGranted() async {
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

  @override
  Future<PermissionStatus> requestNotificationPermission() async {
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
      await _setupSubscription();
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
      InitializationSettings initializationSettings) async {
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
    await _handleApplicationWasLaunchedFromNotification();
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

  Future<void> _zonedScheduleWithFallback({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails details,
    required String payload,
  }) async {
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
          id, title, body, scheduledDate, details,
          payload: payload,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
    } on PlatformException catch (e) {
      if (e.code == 'exact_alarms_not_permitted') {
        await flutterLocalNotificationsPlugin.zonedSchedule(
            id, title, body, scheduledDate, details,
            payload: payload, androidScheduleMode: AndroidScheduleMode.inexact);
      } else {
        rethrow;
      }
    }
  }

  /// Returns a TZDateTime for the birthday's month/day in [year] at 09:00 AM.
  tz.TZDateTime _birthdayInYear(UserBirthday userBirthday, int year) {
    return tz.TZDateTime(
      tz.local,
      year,
      userBirthday.birthdayDate.month,
      userBirthday.birthdayDate.day,
      9,
    );
  }

  @override
  Future<void> scheduleNotificationForBirthday(
      UserBirthday userBirthday, String notificationMessage) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime nextOccurrence = _birthdayInYear(userBirthday, now.year);

    if (nextOccurrence.isBefore(now)) {
      // If it's today and we already passed the scheduled time, show it now.
      if (nextOccurrence.year == now.year &&
          nextOccurrence.month == now.month &&
          nextOccurrence.day == now.day) {
        bool didApplicationLaunchFromNotification =
            await _wasApplicationLaunchedFromNotification();
        if (!didApplicationLaunchFromNotification) {
          await _showNotification(userBirthday, notificationMessage);
        }
      }
      nextOccurrence = _birthdayInYear(userBirthday, now.year + 1);
    }

    await _zonedScheduleWithFallback(
        id: userBirthday.notificationId,
        title: applicationName,
        body: notificationMessage,
        scheduledDate: nextOccurrence,
        details:
            NotificationDetails(android: _createAndroidNotificationDetails()),
        payload: jsonEncode(userBirthday));
  }

  @override
  Future<void> cancelNotificationForBirthday(UserBirthday birthday) async {
    await flutterLocalNotificationsPlugin.cancel(birthday.notificationId);
  }

  @override
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> _handleApplicationWasLaunchedFromNotification() async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails != null &&
        notificationAppLaunchDetails.didNotificationLaunchApp) {
      NotificationResponse? notificationResponse =
          notificationAppLaunchDetails.notificationResponse;
      if (notificationResponse != null) {
        String? payload = notificationResponse.payload;
        selectNotificationStream.add(payload);
        await _rescheduleNotificationFromPayload(payload);
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
      String? payload) async {
    UserBirthday? userBirthday = Utils.getUserBirthdayFromPayload(payload);
    if (userBirthday != null && _notificationMessageProvider != null) {
      await cancelNotificationForBirthday(userBirthday);
      await scheduleNotificationForBirthday(
          userBirthday,
          _notificationMessageProvider!(userBirthday.name));
    }
  }

  @override
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

  Future<void> _setupSubscription() async {
    await _selectSubscription?.cancel();
    _selectSubscription =
        selectNotificationStream.stream.listen((payload) async {
      await _rescheduleNotificationFromPayload(payload);
      for (var listener in selectNotificationStreamListeners) {
        listener.onNotificationSelected(payload);
      }
    });
  }
}
