import 'package:birthday_calendar/ThemeBloc/ThemeBloc.dart';
import 'package:birthday_calendar/service/contacts_service/contacts_service.dart';
import 'package:birthday_calendar/service/contacts_service/contacts_service_impl.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/notification_service/notification_service_impl.dart';
import 'package:birthday_calendar/service/permission_service/permissions_service.dart';
import 'package:birthday_calendar/service/permission_service/permissions_service_impl.dart';
import 'package:birthday_calendar/service/service_locator.dart';
import 'package:birthday_calendar/service/storage_service/shared_preferences_storage.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'service/date_service/date_service.dart';
import 'package:birthday_calendar/page/main_page/main_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final DateService _dateService = getIt<DateService>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  NotificationService notificationService = NotificationServiceImpl();
  PermissionsService permissionsService = PermissionsServiceImpl();
  StorageService storageService = StorageServiceSharedPreferences();
  ContactsService contactsService = ContactsServiceImpl(
      storageService: storageService,
      notificationService: notificationService,
      permissionsService: permissionsService);
  runApp(MyApp(notificationService: notificationService, contactsService: contactsService));
}

class MyApp extends StatelessWidget {

  MyApp({
    required this.notificationService,
    required this.contactsService
  });

  final NotificationService notificationService;
  final ContactsService contactsService;

  @override
  Widget build(BuildContext context) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ThemeBloc())
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
                  title: applicationName,
                  currentMonth: _dateService.getCurrentMonthNumber()
                )
              );
          },
        ),
      );
      }
    }
