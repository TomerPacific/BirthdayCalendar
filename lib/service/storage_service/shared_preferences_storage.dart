import 'dart:convert';
import 'dart:async';
import 'package:birthday_calendar/BirthdayCalendarDateUtils.dart';
import 'package:birthday_calendar/constants.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/model/birthdays_stream_event.dart';
import 'package:intl/intl.dart';
import 'storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

class StorageServiceSharedPreferences extends StorageService {
  final SharedPreferences _sharedPreferences;

  StorageServiceSharedPreferences(this._sharedPreferences);

  StreamController<BirthdaysStreamEvent> streamController =
      StreamController<BirthdaysStreamEvent>.broadcast();

  @override
  Future<void> clearAllBirthdays() async {
    Set<String> keys = _sharedPreferences.getKeys();
    DateFormat format = DateFormat('yyyy-MM-dd');
    for (String key in keys) {
      try {
        format.parse(key);
        await _sharedPreferences.remove(key);
      } catch (error) {}
    }
  }

  @override
  Future<List<UserBirthday>> getBirthdaysForDate(
      DateTime dateTime, bool shouldGetBirthdaysFromSimilarDate) async {
    if (shouldGetBirthdaysFromSimilarDate) {
      List<UserBirthday> birthdays = [];
      List<DateTime> birthdaysWithSimilarDates =
          _getBirthdaysWithSimilarDate(dateTime);
      for (DateTime dateTime in birthdaysWithSimilarDates) {
        List<UserBirthday> decodedBirthdays =
            _decodeBirthdaysFromDate(dateTime);
        birthdays.addAll(decodedBirthdays);
      }

      return birthdays;
    }

    List<UserBirthday> decodedBirthdays =
        _decodeBirthdaysFromDate(dateTime);
    return decodedBirthdays;
  }

  List<UserBirthday> _decodeBirthdaysFromDate(DateTime dateTime) {
    String formattedDate =
        BirthdayCalendarDateUtils.formatDateForSharedPrefs(dateTime);
    String? birthdaysJSON = _sharedPreferences.getString(formattedDate);
    if (birthdaysJSON != null) {
      List decodedBirthdaysForDate = jsonDecode(birthdaysJSON);
      List<UserBirthday> decodedBirthdays = decodedBirthdaysForDate
          .map((decodedBirthday) => UserBirthday.fromJson(decodedBirthday))
          .toList();
      return decodedBirthdays;
    }

    return [];
  }

  List<DateTime> _getBirthdaysWithSimilarDate(DateTime dateTime) {
    List<DateTime> matchingBirthdays = [];
    Set<String> dates = _sharedPreferences.getKeys();

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
    bool? isDarkModeEnabled = _sharedPreferences.getBool(darkModeKey);
    return isDarkModeEnabled != null ? isDarkModeEnabled : false;
  }

  @override
  Future<void> saveBirthdaysForDate(
      DateTime dateTime, List<UserBirthday> birthdays) async {
    String encoded = jsonEncode(birthdays);
    String formattedDate =
        BirthdayCalendarDateUtils.formatDateForSharedPrefs(dateTime);
    await _sharedPreferences.setString(formattedDate, encoded);

    streamController.sink.add(BirthdaysStreamEvent(dateTime, birthdays));
  }

  @override
  Future<void> saveThemeModeSetting(bool isDarkModeEnabled) async {
    await _sharedPreferences.setBool(darkModeKey, isDarkModeEnabled);
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

    await saveBirthdaysForDate(userBirthday.birthdayDate, birthdays);
  }

  @override
  Stream<BirthdaysStreamEvent> getBirthdaysStream() {
    return streamController.stream;
  }

  @override
  Future<void> saveIsContactsPermissionPermanentlyDenied(
      bool isPermanentlyDenied) async {
    await _sharedPreferences.setBool(
        contactsPermissionStatusKey, isPermanentlyDenied);
  }

  @override
  Future<bool> getIsContactPermissionPermanentlyDenied() async {
    bool? isPermanentlyDenied =
        _sharedPreferences.getBool(contactsPermissionStatusKey);
    return isPermanentlyDenied != null ? isPermanentlyDenied : false;
  }

  @override
  Future<void> saveDidAlreadyMigrateNotificationStatus(bool status) async {
    await _sharedPreferences.setBool(
        didAlreadyMigrateNotificationStatusFlag, status);
  }

  @override
  Future<bool> getAlreadyMigrateNotificationStatus() async {
    bool? hasAlreadyMigratedNotificationStatus =
        _sharedPreferences.getBool(didAlreadyMigrateNotificationStatusFlag);
    return hasAlreadyMigratedNotificationStatus != null
        ? hasAlreadyMigratedNotificationStatus
        : false;
  }

  @override
  Future<void> saveDidAlreadyMigrateNotificationIds(bool status) async {
    await _sharedPreferences.setBool(
        didAlreadyMigrateNotificationIdsFlag, status);
  }

  @override
  Future<bool> getAlreadyMigrateNotificationIds() async {
    bool? hasAlreadyMigrated =
        _sharedPreferences.getBool(didAlreadyMigrateNotificationIdsFlag);
    return hasAlreadyMigrated ?? false;
  }

  @override
  Future<List<UserBirthday>> getAllBirthdays() async {
    List<UserBirthday> birthdays = [];
    Set<String> dates = _sharedPreferences.getKeys();

    for (String date in dates) {
      if (!BirthdayCalendarDateUtils.isADate(date)) {
        continue;
      }

      String? birthdaysJSON = _sharedPreferences.getString(date);
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
        birthdays.firstWhereOrNull((element) => element == birthday);
    if (storedBirthday != null) {
      storedBirthday.phoneNumber = birthday.phoneNumber;
      await saveBirthdaysForDate(storedBirthday.birthdayDate, birthdays);
    }
  }

  @override
  Future<void> updateNotificationIdForBirthday(UserBirthday birthday) async {
    // Replace the stored entry with one that carries the new notificationId.
    // Matched by name+month+day so the deterministic ID from the caller is persisted.
    List<UserBirthday> birthdays =
        await getBirthdaysForDate(birthday.birthdayDate, false);
    final int index =
        birthdays.indexWhere((element) => element.equals(birthday));
    if (index == -1) {
      throw StateError(
          'updateNotificationIdForBirthday: no stored entry found for '
          '${birthday.name} on ${birthday.birthdayDate.toIso8601String()}. '
          'Storage may be corrupted or out of sync.');
    }
    birthdays[index] = birthday;
    await saveBirthdaysForDate(birthday.birthdayDate, birthdays);
  }

  @override
  Future<void> setNotificationPermissionState(
      NotificationPermissionState state) async {
    await _sharedPreferences.setInt(notificationsPermissionStatusKey, state.index);
  }

  @override
  Future<NotificationPermissionState> getNotificationPermissionState() async {
    final index = _sharedPreferences.getInt(notificationsPermissionStatusKey);
    if (index == null) return NotificationPermissionState.unknown;
    return NotificationPermissionState.values[index];
  }

  @override
  void dispose() {
    streamController.close();
  }
}
