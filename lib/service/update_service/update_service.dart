
abstract class UpdateService {
  void init(Function onSuccess, Function onFailure);
  bool isUpdateAvailable();
  bool isImmediateUpdatePossible();
  bool isFlexibleUpdatePossible();
  Future<void> applyImmediateUpdate(Function onSuccess, Function onFailure);
  Future<void> startFlexibleUpdate();
  void checkForUpdateAvailability(Function onSuccess, Function onFailure);
}