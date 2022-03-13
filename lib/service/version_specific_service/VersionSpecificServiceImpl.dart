
import 'package:birthday_calendar/model/user_birthday.dart';
import 'VersionSpecificService.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/service_locator.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:birthday_calendar/constants.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:collection/collection.dart';

class VersionSpecificServiceImpl extends VersionSpecificService {

  StorageService _storageService = getIt<StorageService>();
  NotificationService _notificationService = getIt<NotificationService>();

  @override
  void migrateNotificationStatus() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (_isVersionGreaterThan(packageInfo.version, versionToMigrateNotificationStatusFrom)) {
      List<PendingNotificationRequest> pendingNotifications = await _notificationService.getAllScheduledNotifications();
      for(PendingNotificationRequest request in pendingNotifications) {
        if (request.payload != null) {
          String payload = request.payload!;
          UserBirthday userBirthday = UserBirthday.fromJson(jsonDecode(payload));
          if (!userBirthday.hasNotification) {
            List<UserBirthday> birthdays = await _storageService.getBirthdaysForDate(userBirthday.birthdayDate, false);
            UserBirthday? found = birthdays.firstWhereOrNull((element) => element.equals(userBirthday));
            if (found != null) {
              birthdays.remove(found);
              userBirthday.updateNotificationStatus(true);
              birthdays.add(userBirthday);
              _storageService.saveBirthdaysForDate(userBirthday.birthdayDate, birthdays);
            }
          }
        }
      }
      _storageService.saveDidAlreadyMigrateNotificationStatus(true);
    }
  }

  bool _isVersionGreaterThan(String newVersion, String currentVersion){
    List<String> currentVersionSplit = currentVersion.split(".");
    List<String> newVersionSplit = newVersion.split(".");
    bool isNewVersionGreaterThanCurrentVersion = false;
    for (var i = 0 ; i < currentVersionSplit.length; i++){
      isNewVersionGreaterThanCurrentVersion = int.parse(newVersionSplit[i]) > int.parse(currentVersionSplit[i]);
      if(int.parse(newVersionSplit[i]) != int.parse(currentVersionSplit[i])) {
        break;
      }
    }
    return isNewVersionGreaterThanCurrentVersion;
  }

}