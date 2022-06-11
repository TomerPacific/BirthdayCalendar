
import 'package:birthday_calendar/service/update_service/update_service.dart';
import 'package:in_app_update/in_app_update.dart';


class UpdateServiceImpl extends UpdateService {

  late AppUpdateInfo _appUpdateInfo;

  void init() async {
    _appUpdateInfo = await InAppUpdate.checkForUpdate();
  }

  @override
  Future<bool> isUpdateAvailable() async {
      return _appUpdateInfo.updateAvailability == UpdateAvailability.updateAvailable;
  }
  @override
  Future<bool> isImmediateUpdatePossible() async {
    return _appUpdateInfo.immediateUpdateAllowed;
  }

  @override
  Future<bool> isFlexibleUpdatePossible() async {
    return _appUpdateInfo.flexibleUpdateAllowed;
  }


}