
abstract class VersionSpecificService {
  Future<void> migrateNotificationStatus();
  Future<void> migrateNotificationIds(String Function(String name) messageBuilder);
}