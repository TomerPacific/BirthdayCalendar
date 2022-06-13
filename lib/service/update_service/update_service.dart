
abstract class UpdateService {
  void init();
  bool isUpdateAvailable();
  bool isImmediateUpdatePossible();
  bool isFlexibleUpdatePossible();
  Future<void> applyImmediateUpdate();
  Future<void> startFlexibleUpdate();
}