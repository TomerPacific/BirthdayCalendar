abstract class UpdateService {
  void checkForInAppUpdate(Function onSuccess, Function(String) onFailure,
      String userDeniedUpdateMsg, String appUpdateFailedMsg);
  bool isUpdateAvailable();
  bool isImmediateUpdatePossible();
  bool isFlexibleUpdatePossible();
  Future<void> applyImmediateUpdate(Function onSuccess,
      Function(String) onFailure, String userDeniedUpdateMsg, String appUpdateFailedMsg);
  Future<void> startFlexibleUpdate(Function onSuccess,
      Function(String) onFailure, String userDeniedUpdateMsg, String appUpdateFailedMsg);
}
