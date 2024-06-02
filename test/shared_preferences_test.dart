import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/service/date_service/date_service.dart';
import 'package:birthday_calendar/service/date_service/date_service_impl.dart';
import 'package:birthday_calendar/service/storage_service/shared_preferences_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:birthday_calendar/service/service_locator.dart';

void main() {

  setupServiceLocator();
  DateService dateService = DateServiceImpl();
  StorageService _storageService = StorageServiceSharedPreferences(dateService: dateService);

  setUp(() {
    return Future(() async {
      WidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      _storageService.clearAllBirthdays();
    });
  });

  test("SharedPreferences get empty birthday array for date", () async {
    final DateTime dateTime = DateTime(2021, 12, 5);
    final birthdays = await _storageService.getBirthdaysForDate(dateTime, false);
    expect(birthdays.length, 0);
  });

  test("SharedPreferences set birthday for date", () async {
    final DateTime dateTime = DateTime(2021, 12, 5);
    final String phoneNumber =  '+234 500 500 5005';
    final UserBirthday userBirthday = new UserBirthday("Someone", DateTime.now(), false, phoneNumber);
    List<UserBirthday> birthdays = [];
    birthdays.add(userBirthday);
    _storageService.saveBirthdaysForDate(dateTime, birthdays);

    final storedBirthdays = await _storageService.getBirthdaysForDate(dateTime, false);
    expect(storedBirthdays.length, 1);
    expect(storedBirthdays[0].name, userBirthday.name);
    expect(storedBirthdays[0].birthdayDate, userBirthday.birthdayDate);
    expect(storedBirthdays[0].hasNotification, userBirthday.hasNotification);

  });

  test("SharedPreferences clear all birthday for date", () async {
    final DateTime dateTime = DateTime(2021, 12, 5);
    final String phoneNumber =  '+234 500 500 5005';

    final UserBirthday userBirthday = new UserBirthday("Someone", DateTime.now(), false, phoneNumber);
    List<UserBirthday> birthdays = [];
    birthdays.add(userBirthday);
   _storageService.saveBirthdaysForDate(dateTime, birthdays);

    List<UserBirthday> storedBirthdays = await _storageService.getBirthdaysForDate(dateTime, false);
    expect(storedBirthdays.length, 1);

    _storageService.clearAllBirthdays();

    storedBirthdays = await _storageService.getBirthdaysForDate(dateTime, false);

    expect(storedBirthdays.length, 0);

  });

  test("SharedPreferences set ThemeMode to dark mode", () async {
    await _storageService.saveThemeModeSetting(true);
    bool isDarkModeEnabled = await _storageService.getThemeModeSetting();
    expect(isDarkModeEnabled, true);
  });

  test("SharedPreferences default contact permission status is not permanently denied", () async {
    bool isContactsPermissionStatusPermanentlyDenied = await _storageService.getIsContactPermissionPermanentlyDenied();
    expect(isContactsPermissionStatusPermanentlyDenied, false);
  });

}