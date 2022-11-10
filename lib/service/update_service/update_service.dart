
abstract class UpdateService {
  void checkForInAppUpdate(Function onSuccess, Function onFailure);
  bool isUpdateAvailable();
  bool isImmediateUpdatePossible();
  bool isFlexibleUpdatePossible();
  Future<void> applyImmediateUpdate(Function onSuccess, Function onFailure);
  Future<void> startFlexibleUpdate();
}