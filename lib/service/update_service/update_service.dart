import 'package:flutter/foundation.dart';

abstract class UpdateService {
  Future<void> checkForInAppUpdate(VoidCallback onSuccess, ValueChanged<String> onFailure,
      String userDeniedUpdateMsg, String appUpdateFailedMsg);
  bool isUpdateAvailable();
  bool isImmediateUpdatePossible();
  bool isFlexibleUpdatePossible();
  Future<void> applyImmediateUpdate(VoidCallback onSuccess,
      ValueChanged<String> onFailure, String userDeniedUpdateMsg, String appUpdateFailedMsg);
  Future<void> startFlexibleUpdate(VoidCallback onSuccess,
      ValueChanged<String> onFailure, String userDeniedUpdateMsg, String appUpdateFailedMsg);
}
