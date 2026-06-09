
abstract class VersionSpecificService {
  Future<void> migrateNotificationStatus();
  Future<void> migrateNotificationIds();
}