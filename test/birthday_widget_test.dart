import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:birthday_calendar/page/birthday/birthday.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:birthday_calendar/service/service_locator.dart';

var printLog = [];
void print(String s) => printLog.add(s);

void main() {

  setupServiceLocator();


  setUp(() {
    return Future(() async {
      WidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
    });
  });

  testWidgets("BirthdayWidget show birthday for Someone", (WidgetTester tester) async {
    final String phoneNumber =  '+234 500 500 5005';
    UserBirthday userBirthday = new UserBirthday("Someone", DateTime.now(), false, phoneNumber);

    await tester.pumpWidget(
        MaterialApp(
            home: Material(
              child:  new SizedBox(
                      height: 40,
                child: BirthdayWidget(
                    key: Key("123"),
                    birthdayOfPerson: userBirthday,
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

    final String phoneNumber =  '+234 500 500 5005';
    UserBirthday userBirthday = new UserBirthday("Someone", DateTime.now(), false, phoneNumber);

    await tester.pumpWidget(
        MaterialApp(
            home: Material(
                child:  new SizedBox(
                    height: 40,
                    child: BirthdayWidget(
                        key: Key("123"),
                        birthdayOfPerson: userBirthday,
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
    bool sawDeletedMessage = printLog[0].toString().contains('Deleted');
    expect(sawDeletedMessage, true);
  });

  testWidgets("BirthdayWidget press on call button", (WidgetTester tester) async {

    final String phoneNumber =  '+234 500 500 5005';
    UserBirthday userBirthday = new UserBirthday("Someone", DateTime.now(), false, phoneNumber);

    await tester.pumpWidget(
        MaterialApp(
            home: Material(
                child:  new SizedBox(
                    height: 40,
                    child: BirthdayWidget(
                        key: Key("123"),
                        birthdayOfPerson: userBirthday,
                        onDeletePressedCallback: () {},
                        indexOfBirthday: 1)
                )
            )
        )
    );

    await tester.tap(find.descendant(of: find.byType(IconButton), matching: find.byIcon(Icons.call)));
    await tester.pump();

    final callButtonIcon = find.byIcon(Icons.call);
    expect(callButtonIcon, findsOneWidget);
  });
}