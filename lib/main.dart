import 'package:birthday_calendar/ClearNotificationsBloc/ClearNotificationsBloc.dart';
import 'package:birthday_calendar/ContactsPermissionStatusBloc/ContactsPermissionStatusBloc.dart';
import 'package:birthday_calendar/BirthdayCalendarDateUtils.dart';
import 'package:birthday_calendar/ThemeBloc/ThemeBloc.dart';
import 'package:birthday_calendar/VersionBloc/VersionBloc.dart';
import 'package:birthday_calendar/service/contacts_service/contacts_service.dart';
import 'package:birthday_calendar/service/contacts_service/contacts_service_impl.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/notification_service/notification_service_impl.dart';
import 'package:birthday_calendar/service/permission_service/permissions_service.dart';
import 'package:birthday_calendar/service/permission_service/permissions_service_impl.dart';
import 'package:birthday_calendar/service/storage_service/shared_preferences_storage.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:birthday_calendar/page/main_page/main_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:birthday_calendar/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();
  PermissionsService permissionsService = PermissionsServiceImpl();
  StorageService storageService =
      StorageServiceSharedPreferences(sharedPreferences);

  NotificationService notificationService =
      NotificationServiceImpl(permissionsService: permissionsService, storageService: storageService);
  ContactsService contactsService = ContactsServiceImpl(
      storageService: storageService,
      notificationService: notificationService,
      permissionsService: permissionsService);

  bool isDarkMode = await storageService.getThemeModeSetting();

  runApp(BirthdayCalendarApp(
    storageService: storageService,
    notificationService: notificationService,
    contactsService: contactsService,
    isDarkMode: isDarkMode,
  ));
}

class BirthdayCalendarApp extends StatelessWidget {
  BirthdayCalendarApp(
      {required this.storageService,
      required this.notificationService,
      required this.contactsService,
      required this.isDarkMode});

  final StorageService storageService;
  final NotificationService notificationService;
  final ContactsService contactsService;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
        value: storageService,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
                create: (context) => ThemeBloc(
                    context.read<StorageService>(),
                    isDarkMode)),
            BlocProvider(
                create: (context) =>
                    ContactsPermissionStatusBloc(contactsService)),
            BlocProvider(
                create: (context) => ClearNotificationsBloc(
                    context.read<StorageService>(),
                    notificationService)),
            BlocProvider(create: (context) => VersionBloc())
          ],
          child: BlocBuilder<ThemeBloc, ThemeMode>(
            builder: (context, state) {
              return MaterialApp(
                  title: applicationName,
                  localizationsDelegates: [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: [
                    Locale('en'),
                    Locale('hi'),
                    Locale('de'),
                  ],
                  theme: ThemeData.light(),
                  themeMode: state,
                  darkTheme: ThemeData.dark(),
                  home: MainPage(
                      key: Key("BirthdayCalendar"),
                      notificationService: notificationService,
                      contactsService: contactsService,
                      title: applicationName,
                      currentMonth:
                          BirthdayCalendarDateUtils.getCurrentMonthNumber()));
            },
          ),
        ));
  }
}
