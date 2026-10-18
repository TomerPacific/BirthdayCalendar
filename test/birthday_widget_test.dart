import 'package:birthday_calendar/birthday_bloc/birthdays_bloc.dart';
import 'package:birthday_calendar/l10n/app_localizations.dart';
import 'package:birthday_calendar/birthday_bloc/birthdays_state.dart';
import 'package:birthday_calendar/theme_bloc/theme_bloc.dart';
import 'package:birthday_calendar/version_bloc/version_bloc.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/storage_service/shared_preferences_storage.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone_form_field/phone_form_field.dart'
    show PhoneFieldLocalization, PhoneFormField;
import 'package:birthday_calendar/page/birthday/birthday.dart';
import 'package:birthday_calendar/widget/add_birthday_form.dart';
import 'package:flutter/material.dart';
import 'package:birthday_calendar/service/notification_service/notification_callbacks.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:material_ui/material_ui.dart' as mui;

class MockNotificationService implements NotificationService {
  @override
  Future<void> init(
      String Function(String name) notificationMessageProvider) async {}

  @override
  Future<bool> isNotificationPermissionGranted() async => true;

  @override
  Future<PermissionStatus> getNotificationPermissionStatus() async =>
      PermissionStatus.granted;

  @override
  Future<PermissionStatus> requestNotificationPermission() async =>
      PermissionStatus.granted;

  @override
  Future<bool> shouldShowNotificationRationale() async => false;

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

var printLog = [];

void print(String s) => printLog.add(s);

void main() {
  late StorageService storageService;
  NotificationService notificationService = MockNotificationService();
  List<UserBirthday> birthdays = [];

  setUp(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    storageService = StorageServiceSharedPreferences(sharedPreferences);
  });

  Widget base({bool isDarkMode = false}) => RepositoryProvider<StorageService>.value(
      value: storageService,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ThemeBloc(storageService, isDarkMode)),
          BlocProvider(create: (context) => VersionBloc())
        ],
        child: BlocBuilder<ThemeBloc, ThemeMode>(
          builder: (context, state) {
            return MaterialApp(
                title: '',
                locale: const Locale('en'),
                localizationsDelegates: [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  ...PhoneFieldLocalization.delegates,
                ],
                supportedLocales: const [Locale('en'), Locale('hi'), Locale('de')],
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
                                    if (currentState is BirthdaysLoaded &&
                                        currentState.birthdays.isNotEmpty)
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: currentState.birthdays.length,
                                          itemBuilder:
                                              (BuildContext context, int index) {
                                            return BlocProvider.value(
                                                value:
                                                BlocProvider.of<BirthdaysBloc>(
                                                    context),
                                                child: BirthdayWidget(
                                                    key: Key(currentState
                                                        .birthdays[index].name),
                                                    birthdayOfPerson: currentState
                                                        .birthdays[index],
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

  Widget baseAddBirthdayForm({bool isDarkMode = false}) =>
      RepositoryProvider<StorageService>.value(
        value: storageService,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
                create: (context) => ThemeBloc(storageService, isDarkMode)),
            BlocProvider(create: (context) => VersionBloc())
          ],
          child: BlocBuilder<ThemeBloc, ThemeMode>(
            builder: (context, state) {
              return MaterialApp(
                title: '',
                locale: const Locale('en'),
                localizationsDelegates: [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  ...PhoneFieldLocalization.delegates,
                ],
                supportedLocales: const [
                  Locale('en'),
                  Locale('hi'),
                  Locale('de')
                ],
                theme: ThemeData.light(),
                themeMode: state,
                darkTheme: ThemeData.dark(),
                home: Material(
                  child: BlocProvider(
                    create: (context) => BirthdaysBloc(
                        notificationService, storageService, birthdays),
                    child: AddBirthdayForm(
                      dateOfDay: DateTime(2000, 5, 17),
                      notificationService: notificationService,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );

  testWidgets("BirthdayWidget show birthday for Someone",
          (WidgetTester tester) async {
        final String phoneNumber = '+234 500 500 5005';
        UserBirthday userBirthday =
        new UserBirthday("Someone", DateTime.now(), false, phoneNumber);
        birthdays = [userBirthday];
        await tester.pumpWidget(base());

        final nameFinder = find.text('Someone');
        expect(nameFinder, findsOneWidget);
      });

  testWidgets("BirthdayWidget click on remove birthday icon",
          (WidgetTester tester) async {
        final String phoneNumber = '+234 500 500 5005';
        UserBirthday userBirthday =
        new UserBirthday("Someone", DateTime.now(), false, phoneNumber);
        birthdays = [userBirthday];
        await tester.pumpWidget(base());

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

        await tester.pumpWidget(base());

        await tester.tap(find.descendant(
            of: find.byType(IconButton), matching: find.byIcon(Icons.call)));
        await tester.pump();

        final callButtonIcon = find.byIcon(Icons.call);
        expect(callButtonIcon, findsOneWidget);
      });

  group('BirthdayWidget add phone number dialog', () {
    final birthdayDate = DateTime(2000, 5, 17);

    // The dialog persists through StorageService, so the birthday has to
    // exist in storage (not only in the bloc's in-memory list).
    Future<void> seedBirthdayWithoutPhone() async {
      await storageService.saveBirthdaysForDate(
          birthdayDate, [UserBirthday("Someone", birthdayDate, false, "")]);
      birthdays = [UserBirthday("Someone", birthdayDate, false, "")];
    }

    Future<void> openDialog(WidgetTester tester) async {
      await tester.pumpWidget(base());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add_ic_call_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
    }

    // PhoneFormField is built on material_ui's TextField, not Flutter's, so
    // find the shared EditableText underneath instead of byType(TextField).
    Future<void> enterPhoneNumber(WidgetTester tester, String text) async {
      final editable = find.descendant(
          of: find.byType(PhoneFormField), matching: find.byType(EditableText));
      await tester.enterText(editable, text);
      await tester.pump();
    }

    AppLocalizations l10n(WidgetTester tester) =>
        AppLocalizations.of(tester.element(find.byType(AlertDialog)))!;

    Future<String> storedPhoneNumber() async {
      final stored =
      await storageService.getBirthdaysForDate(birthdayDate, false);
      return stored.single.phoneNumber;
    }

    testWidgets("saves a non-US number in international format",
            (WidgetTester tester) async {
          await seedBirthdayWithoutPhone();
          await openDialog(tester);

          await enterPhoneNumber(tester, '+2348012345678');
          await tester
              .tap(find.widgetWithText(TextButton, l10n(tester).add));
          await tester.pumpAndSettle();

          expect(find.byType(AlertDialog), findsNothing);
          expect(await storedPhoneNumber(), '+2348012345678');
          // The row switches from "add phone" to the call button.
          expect(find.byIcon(Icons.call), findsOneWidget);
          expect(find.byIcon(Icons.add_ic_call_outlined), findsNothing);
        });

    testWidgets("applies the default US country to a national number",
            (WidgetTester tester) async {
          await seedBirthdayWithoutPhone();
          await openDialog(tester);

          await enterPhoneNumber(tester, '5551234567');
          await tester
              .tap(find.widgetWithText(TextButton, l10n(tester).add));
          await tester.pumpAndSettle();

          expect(await storedPhoneNumber(), '+15551234567');
        });

    testWidgets("cancel leaves storage and the row unchanged",
            (WidgetTester tester) async {
          await seedBirthdayWithoutPhone();
          await openDialog(tester);

          await enterPhoneNumber(tester, '+2348012345678');
          await tester
              .tap(find.widgetWithText(TextButton, l10n(tester).cancel));
          await tester.pumpAndSettle();

          expect(find.byType(AlertDialog), findsNothing);
          expect(await storedPhoneNumber(), '');
          expect(birthdays.single.phoneNumber, '');
          expect(find.byIcon(Icons.add_ic_call_outlined), findsOneWidget);
          expect(find.byIcon(Icons.call), findsNothing);
        });

    testWidgets("Add with no digits entered keeps the dialog open",
            (WidgetTester tester) async {
          await seedBirthdayWithoutPhone();
          await openDialog(tester);

          await tester
              .tap(find.widgetWithText(TextButton, l10n(tester).add));
          await tester.pumpAndSettle();

          expect(find.byType(AlertDialog), findsOneWidget);
          expect(await storedPhoneNumber(), '');
        });

    testWidgets("mui.Theme follows dark mode brightness",
            (WidgetTester tester) async {
          await seedBirthdayWithoutPhone();
          await tester.pumpWidget(base(isDarkMode: true));
          await tester.pumpAndSettle();
          await tester.tap(find.byIcon(Icons.add_ic_call_outlined));
          await tester.pumpAndSettle();

          final muiTheme = tester.widget<mui.Theme>(find.ancestor(
              of: find.byType(PhoneFormField), matching: find.byType(mui.Theme)));
          expect(muiTheme.data.brightness, Brightness.dark);
        });

    testWidgets("mui.Theme follows light mode brightness",
            (WidgetTester tester) async {
          await seedBirthdayWithoutPhone();
          await tester.pumpWidget(base(isDarkMode: false));
          await tester.pumpAndSettle();
          await tester.tap(find.byIcon(Icons.add_ic_call_outlined));
          await tester.pumpAndSettle();

          final muiTheme = tester.widget<mui.Theme>(find.ancestor(
              of: find.byType(PhoneFormField), matching: find.byType(mui.Theme)));
          expect(muiTheme.data.brightness, Brightness.light);
        });
  });

  group('AddBirthdayForm phone input dialog', () {
    testWidgets("mui.Theme follows dark mode brightness when phone input enabled",
            (WidgetTester tester) async {
          await tester.pumpWidget(baseAddBirthdayForm(isDarkMode: true));
          await tester.pumpAndSettle();

          await tester.tap(find.byIcon(Icons.phone));
          await tester.pumpAndSettle();

          final muiTheme = tester.widget<mui.Theme>(find.ancestor(
              of: find.byType(PhoneFormField), matching: find.byType(mui.Theme)));
          expect(muiTheme.data.brightness, Brightness.dark);
        });

    testWidgets("mui.Theme follows light mode brightness when phone input enabled",
            (WidgetTester tester) async {
          await tester.pumpWidget(baseAddBirthdayForm(isDarkMode: false));
          await tester.pumpAndSettle();

          await tester.tap(find.byIcon(Icons.phone));
          await tester.pumpAndSettle();

          final muiTheme = tester.widget<mui.Theme>(find.ancestor(
              of: find.byType(PhoneFormField), matching: find.byType(mui.Theme)));
          expect(muiTheme.data.brightness, Brightness.light);
        });
  });
}