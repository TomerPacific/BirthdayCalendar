
import 'package:birthday_calendar/service/update_service/update_service.dart';
import 'package:in_app_update/in_app_update.dart';

class UpdateServiceImpl extends UpdateService {

  AppUpdateInfo? _appUpdateInfo;

  void init()  {
    InAppUpdate.checkForUpdate().then((value) => 
      _appUpdateInfo = value
    ).catchError((error) {
      print(error);
    });
  }

  @override
  bool isUpdateAvailable() {
    if (_appUpdateInfo != null) {
      return _appUpdateInfo!.updateAvailability == UpdateAvailability.updateAvailable;
    }
     return false;
  }

  @override
  bool isImmediateUpdatePossible() {
    if (_appUpdateInfo != null) {
      return _appUpdateInfo!.immediateUpdateAllowed;
    }

    return false;
  }

  @override
  bool isFlexibleUpdatePossible() {
    if (_appUpdateInfo != null) {
      return _appUpdateInfo!.flexibleUpdateAllowed;
    }

    return false;
  }

  @override
  Future<void> applyImmediateUpdate() async {
    AppUpdateResult appUpdateResult = await InAppUpdate.performImmediateUpdate();
    if (appUpdateResult == AppUpdateResult.userDeniedUpdate) {

    } else if (appUpdateResult == AppUpdateResult.inAppUpdateFailed) {

    }
  }

  @override
  Future<void> startFlexibleUpdate() async {
    AppUpdateResult appUpdateResult = await InAppUpdate.startFlexibleUpdate();
    if (appUpdateResult == AppUpdateResult.success) {
      InAppUpdate.completeFlexibleUpdate();
    }
  }



}