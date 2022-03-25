
import 'package:birthday_calendar/service/service_locator.dart';
import 'package:birthday_calendar/page/settings_page/settings_screen_manager.dart';
import 'package:flutter/material.dart';

import 'constants.dart';
import 'service/date_service/date_service.dart';
import 'package:birthday_calendar/page/main_page/main_page.dart';

final DateService _dateService = getIt<DateService>();
final SettingsScreenManager _settingsScreenManager = getIt<SettingsScreenManager>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
        return
          ValueListenableBuilder(valueListenable: _settingsScreenManager.themeChangeNotifier, builder: (context, value, child) {
            return MaterialApp(
              title: applicationName,
              theme: ThemeData(),
              darkTheme: ThemeData.dark(),
              themeMode: value == true ? ThemeMode.dark : ThemeMode.light,
              home: MainPage(
                  key: Key("BirthdayCalendar"),
                  title: applicationName,
                  currentMonth: _dateService.getCurrentMonthNumber()
              ),
            );
          });
      }
}
