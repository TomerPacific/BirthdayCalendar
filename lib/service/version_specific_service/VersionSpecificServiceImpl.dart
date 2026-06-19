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
import 'package:pub_semver/pub_semver.dart';

class VersionSpecificServiceImpl extends VersionSpecificService {
  VersionSpecificServiceImpl(
      {required this.storageService, required this.notificationService});

  final StorageService storageService;
  final NotificationService notificationService;

  @override
  Future<void> migrateNotificationStatus() async {
    bool didAlreadyMigrateNotificationStatus =
        await storageService.getAlreadyMigrateNotificationStatus();
    if (didAlreadyMigrateNotificationStatus) {
      return;
    }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (_isVersionGreaterThan(
        packageInfo.version, versionToMigrateNotificationStatusFrom)) {
      List<PendingNotificationRequest> scheduledNotifications =
          await notificationService.getAllScheduledNotifications();
      for (PendingNotificationRequest request in scheduledNotifications) {
        if (request.payload != null) {
          String payload = request.payload!;
          UserBirthday userBirthday =
              UserBirthday.fromJson(jsonDecode(payload));
          if (!userBirthday.hasNotification) {
            List<UserBirthday> birthdays = await storageService
                .getBirthdaysForDate(userBirthday.birthdayDate, false);
            UserBirthday? matchedBirthday = birthdays
                .firstWhereOrNull((element) => element.equals(userBirthday));
            if (matchedBirthday != null) {
              birthdays.remove(matchedBirthday);
              userBirthday.updateNotificationStatus(true);
              birthdays.add(userBirthday);
              await storageService.saveBirthdaysForDate(
                  userBirthday.birthdayDate, birthdays);
            }
          }
        }
      }
      await storageService.saveDidAlreadyMigrateNotificationStatus(true);
    }
  }

  @override
  Future<void> migrateNotificationIds(
      String Function(String name) messageBuilder) async {
    bool didAlreadyMigrate =
        await storageService.getAlreadyMigrateNotificationIds();
    if (didAlreadyMigrate) {
      return;
    }

    // Load birthdays first — if this throws, we haven't cancelled anything yet
    // and the user's existing notifications remain intact.
    List<UserBirthday> allBirthdays = await storageService.getAllBirthdays();

    // Now safe to cancel: we have the full birthday list and can reschedule.
    // Notifications were scheduled under unstable hashCode-based IDs and can
    // no longer be reliably cancelled or matched individually.
    await notificationService.cancelAllNotifications();

    // Reschedule each birthday with a new deterministic ID.
    // Errors are caught per-item so a single failure doesn't leave all other
    // birthdays without notifications.
    bool isMigrationSuccessful = true;
    for (UserBirthday birthday in allBirthdays) {
      final migratedBirthday = UserBirthday(
        birthday.name,
        birthday.birthdayDate,
        birthday.hasNotification,
        birthday.phoneNumber,
        // notificationId omitted — forces recomputation via _deterministicId
      );

      try {
        // Re-save so the persisted JSON carries the new deterministic ID.
        await storageService.updateNotificationIdForBirthday(migratedBirthday);

        if (migratedBirthday.hasNotification) {
          await notificationService.scheduleNotificationForBirthday(
            migratedBirthday,
            messageBuilder(migratedBirthday.name),
          );
        }
      } catch (e, stackTrace) {
        isMigrationSuccessful = false;
        debugPrint(
            'Failed to migrate birthday ${birthday.name}: $e\n$stackTrace');
      }
    }

    // Only mark migration complete if every birthday was migrated successfully,
    // so a partial failure retries on the next launch.
    if (isMigrationSuccessful) {
      await storageService.saveDidAlreadyMigrateNotificationIds(true);
    }
  }

  bool _isVersionGreaterThan(String version, String threshold) {
    Version? parsedVersion = _tryParseVersion(version);
    Version? parsedThreshold = _tryParseVersion(threshold);

    if (parsedVersion != null && parsedThreshold != null) {
      return parsedVersion > parsedThreshold;
    }

    debugPrint(
        "Could not compare versions: version='$version', threshold='$threshold'");
    return false;
  }

  Version? _tryParseVersion(String versionString) {
    try {
      return Version.parse(versionString);
    } catch (_) {
      try {
        return Version.parse(_normalizeToSemVer(versionString));
      } catch (e) {
        debugPrint("Failed to parse version '$versionString': $e");
        return null;
      }
    }
  }

  String _normalizeToSemVer(String versionString) {
    int dashIndex = versionString.indexOf('-');
    int plusIndex = versionString.indexOf('+');
    int splitIndex = -1;

    if (dashIndex != -1 && plusIndex != -1) {
      splitIndex = dashIndex < plusIndex ? dashIndex : plusIndex;
    } else {
      splitIndex = dashIndex != -1 ? dashIndex : plusIndex;
    }

    String versionPart =
        splitIndex == -1 ? versionString : versionString.substring(0, splitIndex);
    String suffix = splitIndex == -1 ? "" : versionString.substring(splitIndex);

    List<String> segments = versionPart.split('.');
    if (segments.length < 3) {
      while (segments.length < 3) {
        segments.add("0");
      }
      return segments.join('.') + suffix;
    }
    return versionString;
  }
}
