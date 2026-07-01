import 'dart:async';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/model/birthdays_stream_event.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:birthday_calendar/widget/calendar_day.dart';
import 'package:birthday_calendar/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:birthday_calendar/service/notification_service/notificationCallbacks.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class MockNotificationService implements NotificationService {
  @override
  Future<void> init(String Function(String name) notificationMessageProvider) async {}

  @override
  Future<bool> isNotificationPermissionGranted() async =>
      true;

  @override
  Future<PermissionStatus> requestNotificationPermission() async =>
      PermissionStatus.granted;

  @override
  Future<void> scheduleNotificationForBirthday(
      UserBirthday userBirthday, String notificationMessage) async {}

  @override
  Future<void> cancelNotificationForBirthday(UserBirthday birthday) async {}

  @override
  Future<void> cancelAllNotifications() async {}

  @override
  Future<List<PendingNotificationRequest>>
      getAllScheduledNotifications() async => [];

  @override
  void dispose() {}

  @override
  void addListenerForSelectNotificationStream(NotificationCallbacks listener) {}

  @override
  void removeListenerForSelectNotificationStream(
      NotificationCallbacks listener) {}
}

class MockStorageService extends StorageService {
  final _controller = StreamController<BirthdaysStreamEvent>.broadcast();

  @override
  Stream<BirthdaysStreamEvent> getBirthdaysStream() => _controller.stream;

  void emit(DateTime date, List<UserBirthday> birthdays) {
    _controller.add(BirthdaysStreamEvent(date, birthdays));
  }

  @override
  Future<void> clearAllBirthdays() async {}

  @override
  Future<List<UserBirthday>> getBirthdaysForDate(
          DateTime dateTime, bool shouldGetBirthdaysFromSimilarDate) async =>
      [];

  @override
  Future<bool> getThemeModeSetting() async => false;

  @override
  Future<void> saveBirthdaysForDate(
      DateTime dateTime, List<UserBirthday> birthdays) async {}

  @override
  Future<void> saveThemeModeSetting(bool isDarkModeEnabled) async {}

  @override
  Future<void> updateNotificationStatusForBirthday(
      UserBirthday userBirthday, bool updatedStatus) async {}

  @override
  Future<void> saveIsContactsPermissionPermanentlyDenied(
      bool isPermanentlyDenied) async {}

  @override
  Future<bool> getIsContactPermissionPermanentlyDenied() async => false;

  @override
  Future<void> saveDidAlreadyMigrateNotificationStatus(bool status) async {}

  @override
  Future<bool> getAlreadyMigrateNotificationStatus() async => false;

  @override
  Future<void> saveDidAlreadyMigrateNotificationIds(bool status) async {}

  @override
  Future<bool> getAlreadyMigrateNotificationIds() async => false;

  @override
  Future<List<UserBirthday>> getAllBirthdays() async => [];

  @override
  Future<void> updatePhoneNumberForBirthday(UserBirthday birthday) async {}

  @override
  Future<void> updateNotificationIdForBirthday(UserBirthday birthday) async {}

  @override
  Future<void> setNotificationPermissionState(
      NotificationPermissionState state) async {}

  @override
  Future<NotificationPermissionState> getNotificationPermissionState() async =>
      NotificationPermissionState.unknown;

  @override
  Future<void> updateContactIdForBirthday(
      UserBirthday birthday, String contactId) async {}

  @override
  Future<void> saveDidAlreadyMigrateContactIds(bool status) async {}

  @override
  Future<bool> getAlreadyMigratedContactIds() async => false;

  void dispose() {
    _controller.close();
  }
}

void main() {
  testWidgets(
      'CalendarDayWidget updates UI when birthday notification status changes',
      (WidgetTester tester) async {
    final mockStorageService = MockStorageService();
    final mockNotificationService = MockNotificationService();
    final date = DateTime(2023, 1, 1);

    await tester.pumpWidget(
      MaterialApp(
        home: Provider<StorageService>.value(
          value: mockStorageService,
          child: CalendarDayWidget(
            key: Key('calendar_day'),
            date: date,
            notificationService: mockNotificationService,
          ),
        ),
      ),
    );

    // Initial state: no birthdays
    expect(find.byIcon(Icons.cake_outlined), findsNothing);

    // Add a birthday
    final birthday = UserBirthday('Test', date, false, '');
    mockStorageService.emit(date, [birthday]);
    await tester.pump();

    expect(find.byIcon(Icons.cake_outlined), findsOneWidget);

    // Update the birthday (e.g., enable notification)
    final updatedBirthday = UserBirthday('Test', date, true, '');
    mockStorageService.emit(date, [updatedBirthday]);
    await tester.pump();

    // Verify it still shows the cake
    expect(find.byIcon(Icons.cake_outlined), findsOneWidget);

    mockStorageService.dispose();
  });

  testWidgets('CalendarDayWidget does not update if mounted is false',
      (WidgetTester tester) async {
    final mockStorageService = MockStorageService();
    final mockNotificationService = MockNotificationService();
    final date = DateTime(2023, 1, 1);

    await tester.pumpWidget(
      MaterialApp(
        home: Provider<StorageService>.value(
          value: mockStorageService,
          child: CalendarDayWidget(
            key: Key('calendar_day'),
            date: date,
            notificationService: mockNotificationService,
          ),
        ),
      ),
    );

    // Unmount the widget
    await tester.pumpWidget(Container());

    // Emit an event
    mockStorageService.emit(date, [UserBirthday('Test', date, false, '')]);

    // Should not crash
    await tester.pump();

    mockStorageService.dispose();
  });
}
