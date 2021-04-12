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
          onDismissed: (DismissDirection direction) {
            if (direction == DismissDirection.endToStart) {
              monthToPresent = (monthToPresent + 1) % 12;
              month = DateService().convertMonthToWord(monthToPresent);
            } else {
              monthToPresent = (monthToPresent - 1) % 12;
              month = DateService().convertMonthToWord(monthToPresent);
            }
            setState(() {});
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
