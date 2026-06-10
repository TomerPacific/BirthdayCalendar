
import 'package:birthday_calendar/model/user_birthday.dart';
import 'VersionSpecificService.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:birthday_calendar/constants.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:collection/collection.dart';

class VersionSpecificServiceImpl extends VersionSpecificService {

  VersionSpecificServiceImpl({
    required this.storageService,
    required this.notificationService
  });

  final StorageService storageService;
  final NotificationService notificationService;


  @override
  Future<void> migrateNotificationStatus() async {

    bool didAlreadyMigrateNotificationStatus = await storageService.getAlreadyMigrateNotificationStatus();
    if (didAlreadyMigrateNotificationStatus) {
      return;
    }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (_isVersionGreaterThan(packageInfo.version, versionToMigrateNotificationStatusFrom)) {
      List<PendingNotificationRequest> pendingNotifications = await notificationService.getAllScheduledNotifications();
      for(PendingNotificationRequest request in pendingNotifications) {
        if (request.payload != null) {
          String payload = request.payload!;
          UserBirthday userBirthday = UserBirthday.fromJson(jsonDecode(payload));
          if (!userBirthday.hasNotification) {
            List<UserBirthday> birthdays = await storageService.getBirthdaysForDate(userBirthday.birthdayDate, false);
            UserBirthday? found = birthdays.firstWhereOrNull((element) => element.equals(userBirthday));
            if (found != null) {
              birthdays.remove(found);
              userBirthday.updateNotificationStatus(true);
              birthdays.add(userBirthday);
              await storageService.saveBirthdaysForDate(userBirthday.birthdayDate, birthdays);
            }
          }
        }
      }
      await storageService.saveDidAlreadyMigrateNotificationStatus(true);
    }
  }

  @override
  Future<void> migrateNotificationIds(String Function(String name) messageBuilder) async {
    bool didAlreadyMigrate = await storageService.getAlreadyMigratedNotificationIds();
    if (didAlreadyMigrate) {
      return;
    }

    // Cancel all notifications — they were scheduled under unstable hashCode-based
    // IDs and can no longer be reliably cancelled or matched.
    await notificationService.cancelAllNotifications();

    // Reschedule notifications for every birthday that had one enabled,
    // now using the deterministic ID computed by UserBirthday._deterministicId.
    // Errors are caught per-item so a single failure doesn't leave all other
    // birthdays without notifications.
    bool allSucceeded = true;
    List<UserBirthday> allBirthdays = await storageService.getAllBirthdays();
    for (UserBirthday birthday in allBirthdays) {
      if (birthday.hasNotification) {
        try {
          await notificationService.scheduleNotificationForBirthday(
            birthday,
            messageBuilder(birthday.name),
          );
        } catch (e) {
          allSucceeded = false;
          debugPrint('Failed to reschedule notification for ${birthday.name}: $e');
        }
      }
    }

    // Only mark migration complete if every notification was rescheduled
    // successfully, so a partial failure retries on the next launch.
    if (allSucceeded) {
      await storageService.saveDidAlreadyMigrateNotificationIds(true);
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