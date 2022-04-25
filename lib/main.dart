
import 'package:birthday_calendar/service/service_locator.dart';
import 'package:birthday_calendar/page/settings_page/settings_screen_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants.dart';
import 'service/date_service/date_service.dart';
import 'package:birthday_calendar/page/main_page/main_screen.dart';

final DateService _dateService = getIt<DateService>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
        return
          ChangeNotifierProvider(
            create: (context) => SettingsScreenManager(),
              builder: (context, provider) {
                return Consumer<SettingsScreenManager>(
                  builder: (context, notifier, child) {
                    return MaterialApp(
                      title: applicationName,
                      theme: ThemeData(),
                      darkTheme: ThemeData.dark(),
                      themeMode: notifier.themeMode,
                      home: MainPage(
                          key: Key("BirthdayCalendar"),
                          title: applicationName,
                          currentMonth: _dateService.getCurrentMonthNumber()
                      ),
                    );
                  }
                );
          });
        }
}
