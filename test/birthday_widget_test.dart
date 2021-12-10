import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/service/notification_service.dart';
import 'package:birthday_calendar/service/shared_prefs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:birthday_calendar/widget/birthday.dart';
import 'package:flutter/material.dart';

var printLog = [];
void print(String s) => printLog.add(s);

void main() {

  setUp(() {
    return Future(() async {
      await NotificationService().init(_onDidReceiveLocalNotification);
      await SharedPrefs().init();
    });
  });

  testWidgets("BirthdayWidget shows birthday for Someone", (WidgetTester tester) async {
    await tester.pumpWidget(
        MaterialApp(
            home: Material(
              child:  new SizedBox(
                      height: 40,
                child: BirthdayWidget(
                    key: Key("123"),
                    birthdayOfPerson: new UserBirthday("Someone", DateTime.now(), false),
                    onDeletePressedCallback: () {},
                    indexOfBirthday: 1)
              )
            )
        )
    );

    final nameFinder = find.text('Someone');
    expect(nameFinder, findsOneWidget);
  });

  testWidgets("BirthdayWidget click on remove notification icon", (WidgetTester tester) async {

    await tester.pumpWidget(
        MaterialApp(
            home: Material(
                child:  new SizedBox(
                    height: 40,
                    child: BirthdayWidget(
                        key: Key("123"),
                        birthdayOfPerson: new UserBirthday("Someone", DateTime.now(), false),
                        onDeletePressedCallback: () {
                          print("Deleted");
                        },
                        indexOfBirthday: 1)
                )
            )
        )
    );

    await tester.tap(find.descendant(of: find.byType(IconButton), matching: find.byIcon(Icons.clear)));

    await tester.pump();

    expect(printLog.length, 1);
    expect(printLog[0], contains('Deleted'));
  });
}

Future<dynamic> _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload) async {

}