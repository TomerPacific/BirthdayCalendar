
import 'package:birthday_calendar/service/service_locator.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:birthday_calendar/service/version_specific_service/VersionSpecificService.dart';

class MainScreenManager {

  int monthToPresent = -1;

  StorageService _storageService = getIt<StorageService>();
  VersionSpecificService _versionSpecificService = getIt<VersionSpecificService>();

  void makeVersionAdjustments() async {
    bool didAlreadyMigrateNotificationStatus = await _storageService.getAlreadyMigrateNotificationStatus();
    if (!didAlreadyMigrateNotificationStatus) {
      _versionSpecificService.migrateNotificationStatus();
    }
  }

  int correctMonthOverflow(int month) {
    if (month == 0) {
      month = 12;
    } else if (month == 13) {
      month = 1;
    }
    return month;
  }

}