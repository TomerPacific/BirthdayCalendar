import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:birthday_calendar/service/shared_prefs.dart';

void main() {

  setUp(() {
    return Future(() async {
      await SharedPrefs().init();
      SharedPrefs().clearAllNotifications();
    });
  });

  test("SharedPreferences get empty birthday array for date", () {
    final DateTime dateTime = DateTime(2021, 12, 5);
    final birthdays = SharedPrefs().getBirthdaysForDate(dateTime);
    expect(birthdays.length, 0);
  });

  test("SharedPreferences set birthday for date", () async {
    final DateTime dateTime = DateTime(2021, 12, 5);

    final UserBirthday userBirthday = new UserBirthday("Someone", dateTime, false);
    List<UserBirthday> birthdays = [];
    birthdays.add(userBirthday);
    SharedPrefs().setBirthdaysForDate(dateTime, birthdays);

    final storedBirthdays = SharedPrefs().getBirthdaysForDate(dateTime);
    expect(storedBirthdays.length, 1);
    expect(storedBirthdays[0].name, equals(userBirthday.name));
    expect(storedBirthdays[0].birthdayDate, equals(userBirthday.birthdayDate));
    expect(storedBirthdays[0].hasNotification, equals(userBirthday.hasNotification));

  });

  test("SharedPreferences clear all birthday for date", () async {
    final DateTime dateTime = DateTime(2021, 12, 5);

    final UserBirthday userBirthday = new UserBirthday("Someone", dateTime, false);
    List<UserBirthday> birthdays = [];
    birthdays.add(userBirthday);
    SharedPrefs().setBirthdaysForDate(dateTime, birthdays);

    List<UserBirthday> storedBirthdays = SharedPrefs().getBirthdaysForDate(dateTime);
    expect(storedBirthdays.length, 1);

    SharedPrefs().clearAllNotifications();

    storedBirthdays = SharedPrefs().getBirthdaysForDate(dateTime);

    expect(storedBirthdays.length, 0);

  });

}