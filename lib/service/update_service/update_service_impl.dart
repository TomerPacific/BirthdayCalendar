
import 'package:birthday_calendar/service/update_service/update_service.dart';
import 'package:in_app_update/in_app_update.dart';


class UpdateServiceImpl extends UpdateService {

  AppUpdateInfo? _appUpdateInfo;

  @override
  Future<bool> isUpdateAvailable() async {
      _appUpdateInfo = await InAppUpdate.checkForUpdate();
      return _appUpdateInfo!.updateAvailability == UpdateAvailability.updateAvailable;
  }
  @override
  Future<bool> isImmediateUpdatePossible() async {
    if (_appUpdateInfo == null) {
      _appUpdateInfo = await InAppUpdate.checkForUpdate();
    }

    return _appUpdateInfo!.immediateUpdateAllowed;
  }

  @override
  Future<bool> isFlexibleUpdatePossible() async {
    if (_appUpdateInfo == null) {
      _appUpdateInfo = await InAppUpdate.checkForUpdate();
    }

    return _appUpdateInfo!.flexibleUpdateAllowed;
  }


}