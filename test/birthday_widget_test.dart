import 'package:birthday_calendar/BirthdayBloc/BirthdaysBloc.dart';
import 'package:birthday_calendar/BirthdayBloc/BirthdaysState.dart';
import 'package:birthday_calendar/ThemeBloc/ThemeBloc.dart';
import 'package:birthday_calendar/VersionBloc/VersionBloc.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/storage_service/shared_preferences_storage.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:birthday_calendar/page/birthday/birthday.dart';
import 'package:flutter/material.dart';
import 'package:birthday_calendar/service/notification_service/notificationCallbacks.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

var printLog = [];

void print(String s) => printLog.add(s);

void main() {
  StorageService storageService = StorageServiceSharedPreferences();
  NotificationService notificationService = MockNotificationService();
  List<UserBirthday> birthdays = [];

  setUp(() {
    return Future(() async {
      WidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
    });
  });

  Widget base = RepositoryProvider<StorageService>.value(
      value: storageService,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ThemeBloc(storageService, false)),
          BlocProvider(create: (context) => VersionBloc())
        ],
        child: BlocBuilder<ThemeBloc, ThemeMode>(
          builder: (context, state) {
            return MaterialApp(
                title: '',
                theme: ThemeData.light(),
                themeMode: state,
                darkTheme: ThemeData.dark(),
                home: Material(
                    child: new SizedBox(
                        height: 40,
                        child: BlocProvider(
                            create: (context) => BirthdaysBloc(
                                notificationService, storageService, birthdays),
                            child: BlocBuilder<BirthdaysBloc, BirthdaysState>(
                                builder: (context, state) {
                              final currentState = state;
                              return Column(children: [
                                if (currentState is BirthdaysLoaded && currentState.birthdays.isNotEmpty)
                                    Expanded(
                                        child: ListView.builder(
                                          itemCount: currentState.birthdays.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return BlocProvider.value(
                                                value: BlocProvider.of<
                                                    BirthdaysBloc>(context),
                                                child: BirthdayWidget(
                                                    key: Key(currentState
                                                        .birthdays[index]
                                                        .name),
                                                    birthdayOfPerson:
                                                        currentState.birthdays[index],
                                                    indexOfBirthday: index,
                                                    notificationService:
                                                        notificationService));
                                          },
                                        ),
                                      )
                                else
                                  Spacer(),
                              ]);
                            })))));
          },
        ),
      ));

  testWidgets("BirthdayWidget show birthday for Someone",
      (WidgetTester tester) async {
    final String phoneNumber = '+234 500 500 5005';
    UserBirthday userBirthday =
        new UserBirthday("Someone", DateTime.now(), false, phoneNumber);
    birthdays = [userBirthday];
    await tester.pumpWidget(base);

    final nameFinder = find.text('Someone');
    expect(nameFinder, findsOneWidget);
  });

  testWidgets("BirthdayWidget click on remove birthday icon",
      (WidgetTester tester) async {
    final String phoneNumber = '+234 500 500 5005';
    UserBirthday userBirthday =
        new UserBirthday("Someone", DateTime.now(), false, phoneNumber);
    birthdays = [userBirthday];
    await tester.pumpWidget(base);

    await tester.tap(find.descendant(
        of: find.byType(IconButton), matching: find.byIcon(Icons.clear)));

    await tester.pumpAndSettle();

    final nameFinder = find.text('Someone');
    expect(nameFinder, findsNothing);
  });

  testWidgets("BirthdayWidget press on call button",
      (WidgetTester tester) async {
    final String phoneNumber = '+234 500 500 5005';
    UserBirthday userBirthday =
        new UserBirthday("Someone", DateTime.now(), false, phoneNumber);

    birthdays = [userBirthday];

    await tester.pumpWidget(base);

    await tester.tap(find.descendant(
        of: find.byType(IconButton), matching: find.byIcon(Icons.call)));
    await tester.pump();

    final callButtonIcon = find.byIcon(Icons.call);
    expect(callButtonIcon, findsOneWidget);
  });
}
