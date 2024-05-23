import 'package:birthday_calendar/ThemeCubit.dart';
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

  @override
  Widget build(BuildContext context) {
          return MaterialApp(
            title: applicationName,
            theme: ThemeData.light(),
            home: BlocProvider<ThemeCubit>(
                  create: (_) => ThemeCubit(),
                  child: MainPage(
                      key: Key("BirthdayCalendar"),
                      title: applicationName,
                      currentMonth: _dateService.getCurrentMonthNumber()
                  )
            )
          );
        }
    }
