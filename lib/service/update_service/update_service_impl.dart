import 'package:birthday_calendar/service/update_service/update_service.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

class UpdateServiceImpl extends UpdateService {
  AppUpdateInfo? _appUpdateInfo;

  @override
  Future<void> checkForInAppUpdate(
      Function onSuccess,
      Function(String) onFailure,
      String userDeniedUpdateMsg,
      String appUpdateFailedMsg) async {
    try {
      _appUpdateInfo = await InAppUpdate.checkForUpdate();
      await _checkForUpdateAvailability(
          onSuccess, onFailure, userDeniedUpdateMsg, appUpdateFailedMsg);
    } catch (error, stackTrace) {
      debugPrint("Failed to check for update: $error\n$stackTrace");
      onFailure(appUpdateFailedMsg);
    }
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
      Function onSuccess,
      Function(String) onFailure,
      String userDeniedUpdateMsg,
      String appUpdateFailedMsg) async {
    try {
      AppUpdateResult appUpdateResult =
          await InAppUpdate.performImmediateUpdate();
      if (appUpdateResult == AppUpdateResult.userDeniedUpdate) {
        onFailure(userDeniedUpdateMsg);
      } else if (appUpdateResult == AppUpdateResult.inAppUpdateFailed) {
        onFailure(appUpdateFailedMsg);
      } else {
        onSuccess();
      }
    } catch (error, stackTrace) {
      debugPrint("Failed to perform immediate update: $error\n$stackTrace");
      onFailure(appUpdateFailedMsg);
    }
  }

  @override
  Future<void> startFlexibleUpdate(
      Function onSuccess,
      Function(String) onFailure,
      String userDeniedUpdateMsg,
      String appUpdateFailedMsg) async {
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
    } catch (error, stackTrace) {
      debugPrint("Failed to start flexible update: $error\n$stackTrace");
      onFailure(appUpdateFailedMsg);
    }
  }

  Future<void> _checkForUpdateAvailability(
      Function onSuccess,
      Function(String) onFailure,
      String userDeniedUpdateMsg,
      String appUpdateFailedMsg) async {
    bool needToUpdate = isUpdateAvailable();
    if (needToUpdate) {
      bool isImmediateUpdateAvailable = isImmediateUpdatePossible();
      if (isImmediateUpdateAvailable) {
        await applyImmediateUpdate(
            onSuccess, onFailure, userDeniedUpdateMsg, appUpdateFailedMsg);
      } else {
        bool isFlexibleUpdateAvailable = isFlexibleUpdatePossible();
        if (isFlexibleUpdateAvailable) {
          await startFlexibleUpdate(
              onSuccess, onFailure, userDeniedUpdateMsg, appUpdateFailedMsg);
        }
      }
    }
  }
}
