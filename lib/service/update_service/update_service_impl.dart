import 'package:birthday_calendar/service/update_service/update_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:in_app_update/in_app_update.dart';

class UpdateServiceImpl extends UpdateService {
  AppUpdateInfo? _appUpdateInfo;

  @override
  void checkForInAppUpdate(
      Function onSuccess, Function(String) onFailure, String userDeniedUpdateMsg, String appUpdateFailedMsg) {
    InAppUpdate.checkForUpdate().then((value) {
      _appUpdateInfo = value;
      _checkForUpdateAvailability(onSuccess, onFailure, userDeniedUpdateMsg, appUpdateFailedMsg);
    }).catchError((error) {
      debugPrint("Failed to check for update: $error");
    });
  }

  @override
  bool isUpdateAvailable() {
    if (_appUpdateInfo != null) {
      return _appUpdateInfo!.updateAvailability ==
          UpdateAvailability.updateAvailable;
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
  Future<void> applyImmediateUpdate(
      Function onSuccess, Function(String) onFailure, String userDeniedUpdateMsg, String appUpdateFailedMsg) async {
    InAppUpdate.performImmediateUpdate()
        .then((appUpdateResult) => {
              if (appUpdateResult == AppUpdateResult.userDeniedUpdate)
                {onFailure(userDeniedUpdateMsg)}
              else if (appUpdateResult == AppUpdateResult.inAppUpdateFailed)
                {onFailure(appUpdateFailedMsg)}
              else
                {onSuccess()}
            })
        .catchError((onError) {
      return onFailure(onError.toString());
    });
  }

  @override
  Future<void> startFlexibleUpdate(
      Function onSuccess, Function(String) onFailure, String userDeniedUpdateMsg, String appUpdateFailedMsg) async {
    try {
      AppUpdateResult appUpdateResult = await InAppUpdate.startFlexibleUpdate();
      if (appUpdateResult == AppUpdateResult.success) {
        await InAppUpdate.completeFlexibleUpdate();
        onSuccess();
      } else if (appUpdateResult == AppUpdateResult.userDeniedUpdate) {
        onFailure(userDeniedUpdateMsg);
      } else if (appUpdateResult == AppUpdateResult.inAppUpdateFailed) {
        onFailure(appUpdateFailedMsg);
      }
    } catch (e) {
      onFailure(e.toString());
    }
  }

  void _checkForUpdateAvailability(
      Function onSuccess, Function(String) onFailure, String userDeniedUpdateMsg, String appUpdateFailedMsg) {
    bool needToUpdate = isUpdateAvailable();
    if (needToUpdate) {
      bool isImmediateUpdateAvailable = isImmediateUpdatePossible();
      if (isImmediateUpdateAvailable) {
        applyImmediateUpdate(onSuccess, onFailure, userDeniedUpdateMsg, appUpdateFailedMsg);
      } else {
        bool isFlexibleUpdateAvailable = isFlexibleUpdatePossible();
        if (isFlexibleUpdateAvailable) {
          startFlexibleUpdate(onSuccess, onFailure, userDeniedUpdateMsg, appUpdateFailedMsg);
        }
      }
    }
  }
}
