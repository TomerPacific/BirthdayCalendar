import 'package:birthday_calendar/constants.dart';
import 'package:birthday_calendar/model/user_birthday.dart';

abstract class StorageService {
  Future<List<UserBirthday>> getBirthdaysForDate(
      DateTime dateTime, bool shouldGetBirthdaysFromSimilarDate);

  Future<void> saveBirthdaysForDate(
      DateTime dateTime, List<UserBirthday> birthdays);

  Future<void> clearAllBirthdays();

  Future<void> updateNotificationStatusForBirthday(
      UserBirthday userBirthday, bool updatedStatus);

  Future<bool> getThemeModeSetting();

  Future<void> saveThemeModeSetting(bool isDarkModeEnabled);

  Stream<List<UserBirthday>> getBirthdaysStream();

  Future<void> saveIsContactsPermissionPermanentlyDenied(bool isPermanentlyDenied);

  Future<bool> getIsContactPermissionPermanentlyDenied();

  Future<void> saveDidAlreadyMigrateNotificationStatus(bool status);

  Future<bool> getAlreadyMigrateNotificationStatus();

  Future<List<UserBirthday>> getAllBirthdays();

  Future<void> updatePhoneNumberForBirthday(UserBirthday birthday);

  Future<void> updateNotificationIdForBirthday(UserBirthday birthday);

  Future<void> setNotificationPermissionState(
      NotificationPermissionState state);

  Future<NotificationPermissionState> getNotificationPermissionState();

  Future<void> saveDidAlreadyMigrateNotificationIds(bool status);

  Future<bool> getAlreadyMigratedNotificationIds();

  void dispose();
}
