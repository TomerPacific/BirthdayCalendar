import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:birthday_calendar/widget/birthday.dart';
import 'package:flutter/material.dart';

void main() {
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
  }
  );
}