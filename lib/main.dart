
import 'service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/service_locator.dart';
import 'package:birthday_calendar/widget/settings_screen.dart';
import 'package:birthday_calendar/widget/settings_screen_manager.dart';
import 'package:flutter/material.dart';

import 'package:birthday_calendar/widget/calendar.dart';
import 'constants.dart';
import 'service/date_service/date_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final SettingsScreenManager settingsScreenManager = getIt<SettingsScreenManager>();
  final DateService _dateService = getIt<DateService>();

  @override
  Widget build(BuildContext context) {
        return
          ValueListenableBuilder(valueListenable: settingsScreenManager.themeChangeNotifier, builder: (context, value, child) {
            return MaterialApp(
              title: applicationName,
              theme: ThemeData(),
              darkTheme: ThemeData.dark(),
              themeMode: value == true ? ThemeMode.dark : ThemeMode.light,
              home: MyHomePage(
                  key: Key("BirthdayCalendar"),
                  title: applicationName,
                  currentMonth: _dateService.getCurrentMonthNumber()
              ),
            );
          });
      }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({required Key key, required this.title, required this.currentMonth}) : super(key: key);

  final String title;
  final int currentMonth;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int monthToPresent = -1;
  String month = "";
  DateService _dateService = getIt<DateService>();
  NotificationService _notificationService = getIt<NotificationService>();

  int _correctMonthOverflow(int month) {
    if (month == 0) {
      month = 12;
    } else if (month == 13) {
      month = 1;
    }
    return month;
  }

  void _calculateNextMonthToShow(AxisDirection direction) {
    setState(() {
      monthToPresent = direction == AxisDirection.left ? monthToPresent + 1 : monthToPresent - 1;
      monthToPresent = _correctMonthOverflow(monthToPresent);
      month = _dateService.convertMonthToWord(monthToPresent);
    });
  }

  void _decideOnNextMonthToShow(DragUpdateDetails details) {
    details.delta.dx > 0 ?
    _calculateNextMonthToShow(AxisDirection.right) :
    _calculateNextMonthToShow(AxisDirection.left);
  }

  Future<dynamic> _onDidReceiveLocalNotification(
      int id,
      String? title,
      String? body,
      String? payload) async {
          showDialog(
              context: context,
              builder: (BuildContext context) =>
                  AlertDialog(
                      title: Text(title ?? ''),
                      content: Text(body ?? ''),
                      actions: [
                        TextButton(
                          child: Text("Ok"),
                           onPressed: () async {
                             _notificationService.handleApplicationWasLaunchedFromNotification(payload ?? '');
                            }
                          )
                      ]
                  )
          );
  }


  @override
  void initState() {
    monthToPresent = widget.currentMonth;
    month = _dateService.convertMonthToWord(monthToPresent);
    _notificationService.init(_onDidReceiveLocalNotification);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
                IconButton(
                  icon: Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()
                    ),
                  );
                },
            )
        ],
      ),
      body:
      new GestureDetector(
      onHorizontalDragUpdate: _decideOnNextMonthToShow,
        child:
        new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          new Padding(
            padding: const EdgeInsets.only(bottom: 50, top: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                new Text(month, style: new TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold))
              ],
            ),
          ),
          new Expanded(child:
            new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              new IconButton(icon:
              new Icon(Icons.chevron_left, color: Colors.black),
                  onPressed: () {
                    _calculateNextMonthToShow(AxisDirection.right);
                  }),
              new Expanded(child:
              new CalendarWidget(
                  key: Key(monthToPresent.toString()),
                  currentMonth:monthToPresent),
              ),
              new IconButton(icon:
              new Icon(Icons.chevron_right, color: Colors.black),
                  onPressed: () {
                    _calculateNextMonthToShow(AxisDirection.left);
                  }),
              ],
            )
          )
        ],
      )
      )
    );
  }
}
