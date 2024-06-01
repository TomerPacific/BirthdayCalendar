
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:birthday_calendar/service/version_specific_service/VersionSpecificService.dart';

class MainScreenManager {

  final StorageService storageService;
  final VersionSpecificService versionSpecificService;

  MainScreenManager(this.storageService, this.versionSpecificService);

  void makeVersionAdjustments() async {
    bool didAlreadyMigrateNotificationStatus = await storageService.getAlreadyMigrateNotificationStatus();
    if (!didAlreadyMigrateNotificationStatus) {
      versionSpecificService.migrateNotificationStatus();
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