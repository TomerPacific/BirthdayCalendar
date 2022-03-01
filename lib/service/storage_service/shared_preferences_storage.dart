import 'dart:convert';
import 'package:birthday_calendar/constants.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'storage_service.dart';
import '../date_service/date_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:birthday_calendar/service/service_locator.dart';

class StorageServiceSharedPreferences extends StorageService {

  DateService _dateService = getIt<DateService>();

  @override
  Future<bool> clearAllBirthdays() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.clear();
  }

  @override
  Future<List<UserBirthday>> getBirthdaysForDate(DateTime dateTime) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    String formattedDate = _dateService.formatDateForSharedPrefs(dateTime);
    String? birthdaysJSON = sharedPreferences.getString(formattedDate);
    if (birthdaysJSON != null) {
      List decodedBirthdaysForDate = jsonDecode(birthdaysJSON);
      List<UserBirthday> birthdays = decodedBirthdaysForDate
          .map((decodedBirthday) => UserBirthday.fromJson(decodedBirthday))
          .toList();
      return birthdays;
    }

    return [];
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
  }

  @override
  Future<void> saveThemeModeSetting(bool isDarkModeEnabled) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(darkModeKey, isDarkModeEnabled);
  }

  @override
  Future<void> updateNotificationStatusForBirthday(UserBirthday userBirthday, bool updatedStatus) async {
    List<UserBirthday> birthdays = await getBirthdaysForDate(userBirthday.birthdayDate);
    for (int i = 0; i < birthdays.length; i++) {
      UserBirthday savedBirthday = birthdays[i];
      if (savedBirthday.equals(userBirthday)) {
        savedBirthday.updateNotificationStatus(updatedStatus);
      }
    }
  }

}