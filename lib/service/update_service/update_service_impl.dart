
import 'package:birthday_calendar/service/update_service/update_service.dart';
import 'package:in_app_update/in_app_update.dart';

class UpdateServiceImpl extends UpdateService {

  AppUpdateInfo? _appUpdateInfo;

  void init(Function onSuccess, Function onFailure)  {
    InAppUpdate.checkForUpdate().then((value) {
      _appUpdateInfo = value;
      _checkForUpdateAvailability(onSuccess, onFailure);
    }).catchError((error) {
      onFailure(error.toString());
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
  Future<void> applyImmediateUpdate(Function onSuccess, Function onFailure) async {
    InAppUpdate.performImmediateUpdate().then((appUpdateResult) => {
    if (appUpdateResult == AppUpdateResult.userDeniedUpdate) {
         onFailure("User denied update")
    } else if (appUpdateResult == AppUpdateResult.inAppUpdateFailed) {
       onFailure("App Update Failed")
    } else {
      onSuccess()
    }
    }).catchError((onError) {
      onFailure(onError);
    });
  }

  @override
  Future<void> startFlexibleUpdate() async {
    AppUpdateResult appUpdateResult = await InAppUpdate.startFlexibleUpdate();
    if (appUpdateResult == AppUpdateResult.success) {
      InAppUpdate.completeFlexibleUpdate();
    }
  }

  void _checkForUpdateAvailability(Function onSuccess, Function onFailure) {
    bool needToUpdate = isUpdateAvailable();
    if (needToUpdate) {
      bool isImmediateUpdateAvailable = isImmediateUpdatePossible();
      if (isImmediateUpdateAvailable) {
        applyImmediateUpdate(onSuccess, onFailure);
      } else {
        bool isFlexibleUpdateAvailable = isFlexibleUpdatePossible();
        if (isFlexibleUpdateAvailable) {
          startFlexibleUpdate();
        }
      }
    }
  }

}