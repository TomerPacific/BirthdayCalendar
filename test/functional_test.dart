import 'package:birthday_calendar/BirthdayBloc/BirthdaysBloc.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/page/birthdays_for_calendar_day_page/birthdays_for_calendar_day.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/storage_service/shared_preferences_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:birthday_calendar/service/notification_service/notificationCallbacks.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:birthday_calendar/ThemeBloc/ThemeBloc.dart';
import 'package:birthday_calendar/VersionBloc/VersionBloc.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:birthday_calendar/l10n/app_localizations.dart';

class MockNotificationService implements NotificationService {
  @override
  Future<void> init(BuildContext context) async {}
  @override
  Future<bool> isNotificationPermissionGranted(BuildContext context) async => true;
  @override
  Future<PermissionStatus> requestNotificationPermission(BuildContext context) async => PermissionStatus.granted;
  @override
  Future<void> scheduleNotificationForBirthday(UserBirthday userBirthday, String notificationMessage) async {}
  @override
  Future<void> cancelNotificationForBirthday(UserBirthday birthday) async {}
  @override
  Future<void> cancelAllNotifications() async {}
  @override
  Future<List<PendingNotificationRequest>> getAllScheduledNotifications() async => [];
  @override
  void dispose() {}
  @override
  void addListenerForSelectNotificationStream(NotificationCallbacks listener) {}
  @override
  void removeListenerForSelectNotificationStream(NotificationCallbacks listener) {}
}

void main() {
  late StorageServiceSharedPreferences storageService;
  late NotificationService notificationService;

  setUp(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    storageService = StorageServiceSharedPreferences();
    notificationService = MockNotificationService();
  });

  Widget createWidgetUnderTest(DateTime date, List<UserBirthday> birthdays) {
    return RepositoryProvider<StorageServiceSharedPreferences>(
      create: (context) => storageService,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ThemeBloc(storageService, false)),
          BlocProvider(create: (context) => VersionBloc()),
        ],
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en'),
          ],
          home: BirthdaysForCalendarDayWidget(
            key: Key("test_page"),
            dateOfDay: date,
            birthdays: birthdays,
            notificationService: notificationService,
          ),
        ),
      ),
    );
  }

  testWidgets("Adding multiple birthdays should preserve all entries", (WidgetTester tester) async {
    final testDate = DateTime(2023, 1, 1);
    await tester.pumpWidget(createWidgetUnderTest(testDate, []));

    // 1. Add first birthday
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, "Person One");
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();

    expect(find.text("Person One"), findsOneWidget);

    // 2. Add second birthday - this used to fail if state was lost
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, "Person Two");
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();

    expect(find.text("Person One"), findsOneWidget);
    expect(find.text("Person Two"), findsOneWidget);
  });

  testWidgets("Toggling notification icon should update state correctly", (WidgetTester tester) async {
    final testDate = DateTime(2023, 1, 1);
    final birthday = UserBirthday("John", testDate, false, "");
    
    // Seed storage so the bloc can find it
    await storageService.saveBirthdaysForDate(testDate, [birthday]);
    
    await tester.pumpWidget(createWidgetUnderTest(testDate, [birthday]));

    // Should initially be off
    expect(find.byIcon(Icons.notifications_off_outlined), findsOneWidget);

    // Tap to turn on
    await tester.tap(find.byIcon(Icons.notifications_off_outlined));
    await tester.pumpAndSettle();

    // Should now be on
    expect(find.byIcon(Icons.notifications_active_outlined), findsOneWidget);

    // Tap to turn off
    await tester.tap(find.byIcon(Icons.notifications_active_outlined));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.notifications_off_outlined), findsOneWidget);
  });
}
