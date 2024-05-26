import 'package:birthday_calendar/ThemeBloc/ThemeBloc.dart';
import 'package:birthday_calendar/service/contacts_service/bc_contacts_service.dart';
import 'package:birthday_calendar/service/contacts_service/bc_contacts_service_impl.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/notification_service/notification_service_impl.dart';
import 'package:birthday_calendar/service/service_locator.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'service/date_service/date_service.dart';
import 'package:birthday_calendar/page/main_page/main_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final DateService _dateService = getIt<DateService>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final NotificationService notificationService = NotificationServiceImpl();
  final BCContactsService contactsService = BCContactsServiceImpl();


  @override
  Widget build(BuildContext context) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ThemeBloc()),
          RepositoryProvider(create: (context) => notificationService),
          RepositoryProvider(create: (context) => contactsService)
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
                  title: applicationName,
                  currentMonth: _dateService.getCurrentMonthNumber()
                )
              );
          },
        ),
      );
      }
    }
