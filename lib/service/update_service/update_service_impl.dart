import 'package:birthday_calendar/service/update_service/update_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:birthday_calendar/l10n/app_localizations.dart';

class UpdateServiceImpl extends UpdateService {
  AppUpdateInfo? _appUpdateInfo;

  void checkForInAppUpdate(
      Function onSuccess, Function onFailure, BuildContext context) {
    InAppUpdate.checkForUpdate().then((value) {
      _appUpdateInfo = value;
      _checkForUpdateAvailability(onSuccess, onFailure, context);
    }).catchError((error) {
      onFailure(error.toString());
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
      Function onSuccess, Function onFailure, BuildContext context) async {
    InAppUpdate.performImmediateUpdate()
        .then((appUpdateResult) => {
              if (appUpdateResult == AppUpdateResult.userDeniedUpdate)
                {onFailure(AppLocalizations.of(context)!.userDeniedUpdate)}
              else if (appUpdateResult == AppUpdateResult.inAppUpdateFailed)
                {onFailure(AppLocalizations.of(context)!.appUpdateFailed)}
              else
                {onSuccess()}
            })
        .catchError((onError) {
      return onFailure(onError);
    });
  }

  @override
  Future<void> startFlexibleUpdate() async {
    AppUpdateResult appUpdateResult = await InAppUpdate.startFlexibleUpdate();
    if (appUpdateResult == AppUpdateResult.success) {
      InAppUpdate.completeFlexibleUpdate();
    }
  }

  void _checkForUpdateAvailability(
      Function onSuccess, Function onFailure, BuildContext context) {
    bool needToUpdate = isUpdateAvailable();
    if (needToUpdate) {
      bool isImmediateUpdateAvailable = isImmediateUpdatePossible();
      if (isImmediateUpdateAvailable) {
        applyImmediateUpdate(onSuccess, onFailure, context);
      } else {
        bool isFlexibleUpdateAvailable = isFlexibleUpdatePossible();
        if (isFlexibleUpdateAvailable) {
          startFlexibleUpdate();
        }
      }
    }
  }
}
