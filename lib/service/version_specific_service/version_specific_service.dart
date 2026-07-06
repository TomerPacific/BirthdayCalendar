import 'package:flutter_contacts/contact.dart';

abstract class VersionSpecificService {
  Future<void> migrateNotificationStatus();
  Future<void> migrateNotificationIds(String Function(String name) messageBuilder);
  Future<void> migrateContactIds(List<Contact> liveContacts);
}