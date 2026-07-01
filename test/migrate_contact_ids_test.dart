import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/storage_service/shared_preferences_storage.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:birthday_calendar/service/version_specific_service/VersionSpecificServiceImpl.dart';
import 'package:birthday_calendar/service/notification_service/notificationCallbacks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockNotificationService implements NotificationService {
  @override
  Future<void> init(String Function(String name) notificationMessageProvider) async {}

  @override
  Future<bool> isNotificationPermissionGranted() async =>
      true;

  @override
  Future<PermissionStatus> requestNotificationPermission() async =>
      PermissionStatus.granted;

  @override
  Future<void> scheduleNotificationForBirthday(
      UserBirthday b, String msg) async {}

  @override
  Future<void> cancelNotificationForBirthday(UserBirthday b) async {}

  @override
  Future<void> cancelAllNotifications() async {}

  @override
  Future<List<PendingNotificationRequest>>
      getAllScheduledNotifications() async => [];

  @override
  void dispose() {}

  @override
  void addListenerForSelectNotificationStream(NotificationCallbacks l) {}

  @override
  void removeListenerForSelectNotificationStream(NotificationCallbacks l) {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Build a [Contact] stub with the two fields [migrateContactIds] uses.
Contact makeContact(String id, String displayName) =>
    Contact(id: id, displayName: displayName);

/// Convenience: read back a stored birthday by name from storage.
Future<UserBirthday?> fetchByName(
    StorageService storage, DateTime date, String name) async {
  final list = await storage.getBirthdaysForDate(date, false);
  try {
    return list.firstWhere((b) => b.name == name);
  } catch (_) {
    return null;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late StorageService storageService;
  late VersionSpecificServiceImpl versionService;
  final date = DateTime(1990, 6, 15);

  setUp(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    storageService = StorageServiceSharedPreferences(prefs);
    versionService = VersionSpecificServiceImpl(
      storageService: storageService,
      notificationService: MockNotificationService(),
    );
  });

  group('migrateContactIds — guard conditions', () {
    test('does nothing when migration flag is already set', () async {
      // Store a legacy birthday and pre-set the flag.
      final legacy = UserBirthday('Alice', date, false, '');
      await storageService.saveBirthdaysForDate(date, [legacy]);
      await storageService.saveDidAlreadyMigrateContactIds(true);

      final contact = makeContact('c-1', 'Alice');
      await versionService.migrateContactIds([contact]);

      // The entry should NOT have been updated because we skipped early.
      final stored = await fetchByName(storageService, date, 'Alice');
      expect(stored?.contactId, equals(''));
    });

    test('sets flag immediately when there are no legacy entries', () async {
      // Store a birthday that already has a contactId.
      final modern = UserBirthday('Alice', date, false, '', contactId: 'c-1');
      await storageService.saveBirthdaysForDate(date, [modern]);

      await versionService.migrateContactIds([]);

      expect(await storageService.getAlreadyMigratedContactIds(), isTrue);
    });

    test('sets flag immediately when storage is completely empty', () async {
      await versionService.migrateContactIds([]);
      expect(await storageService.getAlreadyMigratedContactIds(), isTrue);
    });
  });

  group('migrateContactIds — matching logic', () {
    test('updates contactId when exactly one live contact matches by name',
        () async {
      final legacy = UserBirthday('Alice', date, false, '');
      await storageService.saveBirthdaysForDate(date, [legacy]);

      final contact = makeContact('c-alice', 'Alice');
      await versionService.migrateContactIds([contact]);

      final stored = await fetchByName(storageService, date, 'Alice');
      expect(stored?.contactId, equals('c-alice'));
    });

    test('sets migration flag after successful update', () async {
      final legacy = UserBirthday('Alice', date, false, '');
      await storageService.saveBirthdaysForDate(date, [legacy]);

      await versionService.migrateContactIds([makeContact('c-alice', 'Alice')]);

      expect(await storageService.getAlreadyMigratedContactIds(), isTrue);
    });

    test('skips entry when no live contact matches the name', () async {
      final legacy = UserBirthday('Alice', date, false, '');
      await storageService.saveBirthdaysForDate(date, [legacy]);

      // No contact named Alice in the live list.
      await versionService.migrateContactIds([makeContact('c-bob', 'Bob')]);

      final stored = await fetchByName(storageService, date, 'Alice');
      expect(stored?.contactId, equals(''));
      // Flag is still set because the only failure was a skip, not an error.
      expect(await storageService.getAlreadyMigratedContactIds(), isTrue);
    });

    test(
        'skips entry when multiple live contacts share the same name (ambiguous)',
        () async {
      final legacy = UserBirthday('Alice', date, false, '');
      await storageService.saveBirthdaysForDate(date, [legacy]);

      final contacts = [
        makeContact('c-1', 'Alice'),
        makeContact('c-2', 'Alice'),
      ];
      await versionService.migrateContactIds(contacts);

      final stored = await fetchByName(storageService, date, 'Alice');
      expect(stored?.contactId, equals(''));
      // Ambiguous skips do not prevent the flag from being set.
      expect(await storageService.getAlreadyMigratedContactIds(), isTrue);
    });

    test(
        'migrates only unambiguous entries and leaves ambiguous ones untouched',
        () async {
      final alice = UserBirthday('Alice', date, false, '');
      final bob = UserBirthday('Bob', date, false, '');
      await storageService.saveBirthdaysForDate(date, [alice, bob]);

      // Two Alices (ambiguous), one Bob (unambiguous).
      final contacts = [
        makeContact('c-alice-1', 'Alice'),
        makeContact('c-alice-2', 'Alice'),
        makeContact('c-bob', 'Bob'),
      ];
      await versionService.migrateContactIds(contacts);

      final storedAlice = await fetchByName(storageService, date, 'Alice');
      final storedBob = await fetchByName(storageService, date, 'Bob');
      expect(storedAlice?.contactId, equals(''));
      expect(storedBob?.contactId, equals('c-bob'));
      expect(await storageService.getAlreadyMigratedContactIds(), isTrue);
    });

    test('does not touch entries that already have a contactId', () async {
      final modern =
          UserBirthday('Alice', date, false, '', contactId: 'existing-id');
      await storageService.saveBirthdaysForDate(date, [modern]);

      // Even if a contact matches by name, already-migrated entries are not re-processed
      // because they are filtered out of legacyBirthdays before the loop.
      await versionService.migrateContactIds([makeContact('new-id', 'Alice')]);

      final stored = await fetchByName(storageService, date, 'Alice');
      expect(stored?.contactId, equals('existing-id'));
    });

    test('migrates multiple legacy entries across different dates', () async {
      final date2 = DateTime(1985, 3, 22);
      final alice = UserBirthday('Alice', date, false, '');
      final bob = UserBirthday('Bob', date2, false, '');
      await storageService.saveBirthdaysForDate(date, [alice]);
      await storageService.saveBirthdaysForDate(date2, [bob]);

      final contacts = [
        makeContact('c-alice', 'Alice'),
        makeContact('c-bob', 'Bob'),
      ];
      await versionService.migrateContactIds(contacts);

      final storedAlice = await fetchByName(storageService, date, 'Alice');
      final storedBob = await fetchByName(storageService, date2, 'Bob');
      expect(storedAlice?.contactId, equals('c-alice'));
      expect(storedBob?.contactId, equals('c-bob'));
      expect(await storageService.getAlreadyMigratedContactIds(), isTrue);
    });

    test('preserves all other fields on the updated entry', () async {
      final legacy = UserBirthday(
        'Alice',
        date,
        true,
        '+1 555 0100',
        notificationId: 42,
      );
      await storageService.saveBirthdaysForDate(date, [legacy]);

      await versionService.migrateContactIds([makeContact('c-alice', 'Alice')]);

      final stored = await fetchByName(storageService, date, 'Alice');
      expect(stored?.hasNotification, isTrue);
      expect(stored?.phoneNumber, equals('+1 555 0100'));
      expect(stored?.notificationId, equals(42));
      expect(stored?.contactId, equals('c-alice'));
    });

    test(
        'is idempotent — running twice does not overwrite already-set contactIds',
        () async {
      final legacy = UserBirthday('Alice', date, false, '');
      await storageService.saveBirthdaysForDate(date, [legacy]);

      final contacts = [makeContact('c-alice', 'Alice')];
      await versionService.migrateContactIds(contacts);
      // Second run should exit at the guard (flag already set).
      await versionService.migrateContactIds(contacts);

      final stored = await fetchByName(storageService, date, 'Alice');
      expect(stored?.contactId, equals('c-alice'));
    });
  });
}
