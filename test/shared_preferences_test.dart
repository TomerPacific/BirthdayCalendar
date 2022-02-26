import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:birthday_calendar/service/StorageService.dart';
import 'package:birthday_calendar/service/service_locator.dart';

void main() {

  setupServiceLocator();
  StorageService _storageService = getIt<StorageService>();

  setUp(() {
    return Future(() async {
      WidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      _storageService.clearAllBirthdays();
    });
  });

  test("SharedPreferences get empty birthday array for date", () async {
    final DateTime dateTime = DateTime(2021, 12, 5);
    final birthdays = await _storageService.getBirthdaysForDate(dateTime);
    expect(birthdays.length, 0);
  });

  test("SharedPreferences set birthday for date", () async {
    final DateTime dateTime = DateTime(2021, 12, 5);
    final String phoneNumber =  '+234 500 500 5005';
    final UserBirthday userBirthday = new UserBirthday("Someone", DateTime.now(), false, phoneNumber);
    List<UserBirthday> birthdays = [];
    birthdays.add(userBirthday);
    _storageService.saveBirthdaysForDate(dateTime, birthdays);

    final storedBirthdays = await _storageService.getBirthdaysForDate(dateTime);
    expect(storedBirthdays.length, 1);
    expect(storedBirthdays[0].name, equals(userBirthday.name));
    expect(storedBirthdays[0].birthdayDate, equals(userBirthday.birthdayDate));
    expect(storedBirthdays[0].hasNotification, equals(userBirthday.hasNotification));

  });

  test("SharedPreferences clear all birthday for date", () async {
    final DateTime dateTime = DateTime(2021, 12, 5);
    final String phoneNumber =  '+234 500 500 5005';

    final UserBirthday userBirthday = new UserBirthday("Someone", DateTime.now(), false, phoneNumber);
    List<UserBirthday> birthdays = [];
    birthdays.add(userBirthday);
   _storageService.saveBirthdaysForDate(dateTime, birthdays);

    List<UserBirthday> storedBirthdays = await _storageService.getBirthdaysForDate(dateTime);
    expect(storedBirthdays.length, 1);

    _storageService.clearAllBirthdays();

    storedBirthdays = await _storageService.getBirthdaysForDate(dateTime);

    expect(storedBirthdays.length, 0);

  });

}