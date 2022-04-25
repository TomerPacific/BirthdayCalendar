
import 'package:birthday_calendar/page/main_page/main_screen_manager.dart';
import 'package:birthday_calendar/page/settings_page/settings_screen_manager.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:birthday_calendar/page/settings_page/settings_screen.dart';
import 'package:birthday_calendar/widget/calendar.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/date_service/date_service.dart';
import 'package:birthday_calendar/service/service_locator.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  MainPage({required Key key, required this.title, required this.currentMonth}) : super(key: key);

  final String title;
  final int currentMonth;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  int monthToPresent = -1;
  String month = "";
  NotificationService _notificationService = getIt<NotificationService>();
  DateService _dateService = getIt<DateService>();
  StorageService _storageService = getIt<StorageService>();

  MainScreenManager _mainScreenManager = MainScreenManager();

  void _calculateNextMonthToShow(AxisDirection direction) {
    setState(() {
      monthToPresent = direction == AxisDirection.left ? monthToPresent + 1 : monthToPresent - 1;
      monthToPresent = _mainScreenManager.correctMonthOverflow(monthToPresent);
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
    _mainScreenManager.makeVersionAdjustments();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MainPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    monthToPresent = widget.currentMonth;
    month = _dateService.convertMonthToWord(monthToPresent);
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
                        MaterialPageRoute(builder: (context) => SettingsScreen()),
                        ).then((result) {
                          if (result == true) {
                            setState(() {});
                            Provider.of<SettingsScreenManager>(context, listen: false).setOnClearBirthdaysFlag(false);
                          }
                        });
                  },
               )
              ],
          ),
      body:
            new GestureDetector(
                onHorizontalDragUpdate: _decideOnNextMonthToShow,
                child:
                Column(
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
                        new Icon(Icons.chevron_left),
                            onPressed: () {
                              _calculateNextMonthToShow(AxisDirection.right);
                            }),
                        new Expanded(child:
                        new CalendarWidget(
                            key: Key(monthToPresent.toString()),
                            currentMonth:monthToPresent),
                        ),
                        new IconButton(icon:
                        new Icon(Icons.chevron_right),
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

  @override void dispose() {
    _storageService.dispose();
    super.dispose();
  }
}