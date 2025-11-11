import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/service/notification_service/notification_service_impl.dart';

abstract class StorageService {
  Future<List<UserBirthday>> getBirthdaysForDate(
      DateTime dateTime, bool shouldGetBirthdaysFromSimilarDate);

  Future<void> saveBirthdaysForDate(
      DateTime dateTime, List<UserBirthday> birthdays);

  void clearAllBirthdays();

  Future<void> updateNotificationStatusForBirthday(
      UserBirthday userBirthday, bool updatedStatus);

  Future<bool> getThemeModeSetting();

  Future<void> saveThemeModeSetting(bool isDarkModeEnabled);

  Stream<List<UserBirthday>> getBirthdaysStream();

  void saveIsContactsPermissionPermanentlyDenied(bool isPermanentlyDenied);

  Future<bool> getIsContactPermissionPermanentlyDenied();

  void saveDidAlreadyMigrateNotificationStatus(bool status);

  Future<bool> getAlreadyMigrateNotificationStatus();

  Future<List<UserBirthday>> getAllBirthdays();

  Future<void> updatePhoneNumberForBirthday(UserBirthday birthday);

  Future<void> setNotificationPermissionState(
      NotificationPermissionState state);

  Future<NotificationPermissionState> getNotificationPermissionState();

  void dispose();
}
