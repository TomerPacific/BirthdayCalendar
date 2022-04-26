import 'dart:convert';
import 'dart:async';
import 'package:birthday_calendar/constants.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:intl/intl.dart';
import 'storage_service.dart';
import '../date_service/date_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:birthday_calendar/service/service_locator.dart';

class StorageServiceSharedPreferences extends StorageService {

  DateService _dateService = getIt<DateService>();
  StreamController<List<UserBirthday>> streamController = StreamController<List<UserBirthday>>.broadcast();

  @override
  void clearAllBirthdays() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    Set<String> keys = sharedPreferences.getKeys();
    DateFormat format = DateFormat('yyyy-MM-dd');
    for (String key in keys) {
        try {
          format.parse(key);
          sharedPreferences.remove(key);
        } catch (error) {

        }
    }
  }

  @override
  Future<List<UserBirthday>> getBirthdaysForDate(DateTime dateTime, bool shouldGetBirthdaysFromSimilarDate) async {

    if (shouldGetBirthdaysFromSimilarDate) {
      List<UserBirthday> birthdays = [];
      List<DateTime> birthdaysWithSimilarDates = await _getBirthdaysWithSimilarDate(dateTime);
      for (DateTime dateTime in birthdaysWithSimilarDates) {
          List<UserBirthday> decodedBirthdays = await _decodeBirthdaysFromDate(dateTime);
          birthdays.addAll(decodedBirthdays);
      }

      return birthdays;
    }

    List<UserBirthday> decodedBirthdays = await _decodeBirthdaysFromDate(dateTime);
    return decodedBirthdays;

  }

  Future<List<UserBirthday>> _decodeBirthdaysFromDate(DateTime dateTime) async {
    final sharedPreferences = await SharedPreferences.getInstance();

    String formattedDate = _dateService.formatDateForSharedPrefs(dateTime);
    String? birthdaysJSON = sharedPreferences.getString(formattedDate);
    if (birthdaysJSON != null) {
      List decodedBirthdaysForDate = jsonDecode(birthdaysJSON);
      List<UserBirthday> decodedBirthdays = decodedBirthdaysForDate
          .map((decodedBirthday) => UserBirthday.fromJson(decodedBirthday))
          .toList();
      return decodedBirthdays;
    }

    return [];
  }

  Future<List<DateTime>> _getBirthdaysWithSimilarDate(DateTime dateTime) async {
    List<DateTime> matchingBirthdays = [];
    final sharedPreferences = await SharedPreferences.getInstance();
    Set<String> dates = sharedPreferences.getKeys();

    for (String date in dates) {

      if (!_dateService.isADate(date)) {
        continue;
      }
      
      DateTime converted = DateTime.parse(date);
      if (dateTime.month == converted.month && dateTime.day == converted.day) {
        matchingBirthdays.add(converted);
      }
    }

    return matchingBirthdays;
  }

  @override
  Future<bool> getThemeModeSetting() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    bool? isDarkModeEnabled = sharedPreferences.getBool(darkModeKey);
    return isDarkModeEnabled != null ? isDarkModeEnabled : false;
  }

  @override
  Future<void> saveBirthdaysForDate(DateTime dateTime, List<UserBirthday> birthdays) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    String encoded = jsonEncode(birthdays);
    String formattedDate = _dateService.formatDateForSharedPrefs(dateTime);
    sharedPreferences.setString(formattedDate, encoded);

    streamController.sink.add(birthdays);
  }

  @override
  Future<void> saveThemeModeSetting(bool isDarkModeEnabled) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(darkModeKey, isDarkModeEnabled);
  }

  @override
  Future<void> updateNotificationStatusForBirthday(UserBirthday userBirthday, bool updatedStatus) async {
    List<UserBirthday> birthdays = await getBirthdaysForDate(userBirthday.birthdayDate, false);
    for (int i = 0; i < birthdays.length; i++) {
      UserBirthday savedBirthday = birthdays[i];
      if (savedBirthday.equals(userBirthday)) {
        savedBirthday.updateNotificationStatus(updatedStatus);
      }
    }

    saveBirthdaysForDate(userBirthday.birthdayDate, birthdays);
  }

  @override
  Stream<List<UserBirthday>> getBirthdaysStream() {
    return streamController.stream;
  }

  void saveIsContactsPermissionPermanentlyDenied(bool isPermanentlyDenied) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(contactsPermissionStatusKey, isPermanentlyDenied);
  }

  Future<bool> getIsContactPermissionPermanentlyDenied() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    bool? isPermanentlyDenied = sharedPreferences.getBool(contactsPermissionStatusKey);
    return isPermanentlyDenied != null ? isPermanentlyDenied : false;
  }

  void saveDidAlreadyMigrateNotificationStatus(bool status) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(didAlreadyMigrateNotificationStatusFlag, status);
  }


  Future<bool> getAlreadyMigrateNotificationStatus() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    bool? hasAlreadyMigratedNotificationStatus = sharedPreferences.getBool(didAlreadyMigrateNotificationStatusFlag);
    return hasAlreadyMigratedNotificationStatus != null ? hasAlreadyMigratedNotificationStatus : false;
  }

  void dispose() {
    streamController.close();
  }
}