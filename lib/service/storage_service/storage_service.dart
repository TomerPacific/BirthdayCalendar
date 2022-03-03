
import 'package:birthday_calendar/model/user_birthday.dart';

abstract class StorageService {
  Future<List<UserBirthday>> getBirthdaysForDate(DateTime dateTime);
  Future<void> saveBirthdaysForDate(DateTime dateTime, List<UserBirthday> birthdays);
  Future<bool> clearAllBirthdays();
  Future<void> updateNotificationStatusForBirthday(UserBirthday userBirthday, bool updatedStatus);

  Future<bool> getThemeModeSetting();
  Future<void> saveThemeModeSetting(bool isDarkModeEnabled);
  Stream<List<UserBirthday>> getBirthdaysStream();
  void dispose();
}