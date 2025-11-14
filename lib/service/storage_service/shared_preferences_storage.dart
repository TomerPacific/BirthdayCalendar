import 'dart:convert';
import 'dart:async';
import 'package:birthday_calendar/BirthdayCalendarDateUtils.dart';
import 'package:birthday_calendar/constants.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:intl/intl.dart';
import 'storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

const String kNotifPermissionStateKey = 'notif_permission_state';

class StorageServiceSharedPreferences extends StorageService {
  StreamController<List<UserBirthday>> streamController =
      StreamController<List<UserBirthday>>.broadcast();

  @override
  void clearAllBirthdays() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    Set<String> keys = sharedPreferences.getKeys();
    DateFormat format = DateFormat('yyyy-MM-dd');
    for (String key in keys) {
      try {
        format.parse(key);
        sharedPreferences.remove(key);
      } catch (error) {}
    }
  }

  @override
  Future<List<UserBirthday>> getBirthdaysForDate(
      DateTime dateTime, bool shouldGetBirthdaysFromSimilarDate) async {
    if (shouldGetBirthdaysFromSimilarDate) {
      List<UserBirthday> birthdays = [];
      List<DateTime> birthdaysWithSimilarDates =
          await _getBirthdaysWithSimilarDate(dateTime);
      for (DateTime dateTime in birthdaysWithSimilarDates) {
        List<UserBirthday> decodedBirthdays =
            await _decodeBirthdaysFromDate(dateTime);
        birthdays.addAll(decodedBirthdays);
      }

      return birthdays;
    }

    List<UserBirthday> decodedBirthdays =
        await _decodeBirthdaysFromDate(dateTime);
    return decodedBirthdays;
  }

  Future<List<UserBirthday>> _decodeBirthdaysFromDate(DateTime dateTime) async {
    final sharedPreferences = await SharedPreferences.getInstance();

    String formattedDate =
        BirthdayCalendarDateUtils.formatDateForSharedPrefs(dateTime);
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
      if (!BirthdayCalendarDateUtils.isADate(date)) {
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
  Future<void> saveBirthdaysForDate(
      DateTime dateTime, List<UserBirthday> birthdays) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    String encoded = jsonEncode(birthdays);
    String formattedDate =
        BirthdayCalendarDateUtils.formatDateForSharedPrefs(dateTime);
    sharedPreferences.setString(formattedDate, encoded);

    streamController.sink.add(birthdays);
  }

  @override
  Future<void> saveThemeModeSetting(bool isDarkModeEnabled) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(darkModeKey, isDarkModeEnabled);
  }

  @override
  Future<void> updateNotificationStatusForBirthday(
      UserBirthday userBirthday, bool updatedStatus) async {
    List<UserBirthday> birthdays =
        await getBirthdaysForDate(userBirthday.birthdayDate, false);
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

  @override
  void saveIsContactsPermissionPermanentlyDenied(
      bool isPermanentlyDenied) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(contactsPermissionStatusKey, isPermanentlyDenied);
  }

  @override
  Future<bool> getIsContactPermissionPermanentlyDenied() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    bool? isPermanentlyDenied =
        sharedPreferences.getBool(contactsPermissionStatusKey);
    return isPermanentlyDenied != null ? isPermanentlyDenied : false;
  }

  @override
  void saveDidAlreadyMigrateNotificationStatus(bool status) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(didAlreadyMigrateNotificationStatusFlag, status);
  }

  @override
  Future<bool> getAlreadyMigrateNotificationStatus() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    bool? hasAlreadyMigratedNotificationStatus =
        sharedPreferences.getBool(didAlreadyMigrateNotificationStatusFlag);
    return hasAlreadyMigratedNotificationStatus != null
        ? hasAlreadyMigratedNotificationStatus
        : false;
  }

  @override
  Future<List<UserBirthday>> getAllBirthdays() async {
    List<UserBirthday> birthdays = [];
    final sharedPreferences = await SharedPreferences.getInstance();
    Set<String> dates = sharedPreferences.getKeys();

    for (String date in dates) {
      if (!BirthdayCalendarDateUtils.isADate(date)) {
        continue;
      }

      String? birthdaysJSON = sharedPreferences.getString(date);
      if (birthdaysJSON != null) {
        List decodedBirthdaysForDate = jsonDecode(birthdaysJSON);
        List<UserBirthday> userBirthdays = decodedBirthdaysForDate
            .map((decodedBirthday) => UserBirthday.fromJson(decodedBirthday))
            .toList();
        birthdays = birthdays + userBirthdays;
      }
    }

    return birthdays;
  }

  @override
  Future<void> updatePhoneNumberForBirthday(UserBirthday birthday) async {
    List<UserBirthday> birthdays =
        await getBirthdaysForDate(birthday.birthdayDate, false);
    UserBirthday? storedBirthday =
        birthdays.firstWhereOrNull((element) => element.name == birthday.name);
    if (storedBirthday != null) {
      storedBirthday.phoneNumber = birthday.phoneNumber;
      saveBirthdaysForDate(storedBirthday.birthdayDate, birthdays);
    }
  }

  @override
  Future<void> setNotificationPermissionState(
      NotificationPermissionState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(kNotifPermissionStateKey, state.index);
  }

  @override
  Future<NotificationPermissionState> getNotificationPermissionState() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(kNotifPermissionStateKey);
    if (index == null) return NotificationPermissionState.unknown;
    return NotificationPermissionState.values[index];
  }

  void dispose() {
    streamController.close();
  }
}
