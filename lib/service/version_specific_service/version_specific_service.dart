import 'package:flutter_contacts/flutter_contacts.dart' as fc;

abstract class VersionSpecificService {
  Future<void> migrateNotificationStatus();
  Future<void> migrateNotificationIds(
      String Function(String name) messageBuilder);
  Future<void> migrateContactIds(List<fc.Contact>? liveContacts);
}
