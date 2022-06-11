
abstract class UpdateService {
  Future<bool> isUpdateAvailable();
  Future<bool> isImmediateUpdatePossible();
  Future<bool> isFlexibleUpdatePossible();
}