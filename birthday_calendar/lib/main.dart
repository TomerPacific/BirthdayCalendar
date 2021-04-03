import 'package:birthday_calendar/CalendarWidget.dart';
import 'package:birthday_calendar/DateService.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:birthday_calendar/SharedPrefs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs().init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: APPLICATION_NAME,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: APPLICATION_NAME),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(DateService().getCurrentMonthName(),
                  style: new TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold
                  )
              ),
              SizedBox(height: 10),
              CalendarWidget(currentMonth: DateService().getCurrentMonthNumber())
            ],
          ),
        )
        ),
      );
  }
}
