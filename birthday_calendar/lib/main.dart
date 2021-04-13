import 'package:flutter/material.dart';

import 'package:birthday_calendar/widget/calendar.dart';
import 'constants.dart';
import 'package:birthday_calendar/service/date_service.dart';
import 'package:birthday_calendar/service/notification_service.dart';
import 'package:birthday_calendar/service/shared_prefs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs().init();
  await NotificationService().init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: applicationName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
          title: applicationName,
          currentMonth: DateService().getCurrentMonthNumber()
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.currentMonth}) : super(key: key);

  final String title;
  final int currentMonth;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int monthToPresent;
  String month;

  void _calculateNextMonthToShow(DismissDirection direction) {
    monthToPresent = direction == DismissDirection.endToStart ? monthToPresent + 1 : monthToPresent - 1;
    if (monthToPresent == 0) {
      monthToPresent = 12;
    } else if (monthToPresent == 13) {
      monthToPresent = 1;
    }
    month = DateService().convertMonthToWord(monthToPresent);
    setState(() {});
  }

  Widget _showNextMonthOnDismissal(int swipeDirection) {
    int monthNumber = swipeDirection == 0 ? monthToPresent - 1 : monthToPresent + 1;

    if (monthNumber == 0) {
      monthNumber = 12;
    } else if (monthNumber == 13) {
      monthNumber = 1;
    }

    String backgroundMonth = DateService().convertMonthToWord(monthNumber);

    return Center(
        child: SingleChildScrollView(
            child: Column(
              children: [
                Text(backgroundMonth, style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                CalendarWidget(currentMonth:monthNumber)
              ],
            )
        )
    );
  }

  @override
  void initState() {
    monthToPresent = widget.currentMonth;
    month = DateService().convertMonthToWord(monthToPresent);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(month),
      ),
      body: new Dismissible(
          key: new ValueKey(monthToPresent),
          background: _showNextMonthOnDismissal(swipeDirectionLeft),
          secondaryBackground: _showNextMonthOnDismissal(swipeDirectionRight),
          onDismissed: (DismissDirection direction) {
            _calculateNextMonthToShow(direction);
          },
          child: Center(
              child: SingleChildScrollView(
              child: Column(
              children: [
                  Text(month,
                  style:
                  new TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              CalendarWidget(currentMonth:monthToPresent)
              ],
            ),
          )
        )
      )
    );
  }
}
