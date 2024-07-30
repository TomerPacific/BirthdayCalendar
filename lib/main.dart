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


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  NotificationService notificationService = NotificationServiceImpl();
  PermissionsService permissionsService = PermissionsServiceImpl();
  StorageService storageService =
      StorageServiceSharedPreferences();
  ContactsService contactsService = ContactsServiceImpl(
      storageService: storageService,
      notificationService: notificationService,
      permissionsService: permissionsService);

  bool isDarkMode = await storageService.getThemeModeSetting();

  runApp(MyApp(
      notificationService: notificationService,
      contactsService: contactsService,
      storageService: storageService,
      isDarkMode: isDarkMode,
  ));
}

class MyApp extends StatelessWidget {
  MyApp(
      {required this.notificationService,
      required this.contactsService,
      required this.storageService,
      required this.isDarkMode});

  final NotificationService notificationService;
  final ContactsService contactsService;
  final StorageService storageService;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeBloc(storageService, isDarkMode)),
        BlocProvider(
            create: (context) => ContactsPermissionStatusBloc(contactsService)),
        BlocProvider(create: (context) => VersionBloc())
      ],
      child: BlocBuilder<ThemeBloc, ThemeMode>(
        builder: (context, state) {
          return MaterialApp(
              title: applicationName,
              theme: ThemeData.light(),
              themeMode: state,
              darkTheme: ThemeData.dark(),
              home: MainPage(
                  key: Key("BirthdayCalendar"),
                  notificationService: notificationService,
                  contactsService: contactsService,
                  storageService: storageService,
                  title: applicationName,
                  currentMonth: BirthdayCalendarDateUtils.getCurrentMonthNumber()));
        },
      ),
    );
  }
}
