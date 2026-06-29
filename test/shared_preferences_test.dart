import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/service/storage_service/shared_preferences_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';

void main() {
  late StorageService _storageService;

  setUp(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    _storageService = StorageServiceSharedPreferences(sharedPreferences);
    await _storageService.clearAllBirthdays();
  });

  test("SharedPreferences get empty birthday array for date", () async {
    final DateTime dateTime = DateTime(2021, 12, 5);
    final birthdays =
        await _storageService.getBirthdaysForDate(dateTime, false);
    expect(birthdays.length, 0);
  });

  test("SharedPreferences set birthday for date", () async {
    final DateTime dateTime = DateTime(2021, 12, 5);
    final String phoneNumber = '+234 500 500 5005';
    final UserBirthday userBirthday =
        new UserBirthday("Someone", DateTime.now(), false, phoneNumber);
    List<UserBirthday> birthdays = [];
    birthdays.add(userBirthday);
    await _storageService.saveBirthdaysForDate(dateTime, birthdays);

    final storedBirthdays =
        await _storageService.getBirthdaysForDate(dateTime, false);
    expect(storedBirthdays.length, 1);
    expect(storedBirthdays[0].name, userBirthday.name);
    expect(storedBirthdays[0].birthdayDate, userBirthday.birthdayDate);
    expect(storedBirthdays[0].hasNotification, userBirthday.hasNotification);
  });

  test("SharedPreferences clear all birthday for date", () async {
    final DateTime dateTime = DateTime(2021, 12, 5);
    final String phoneNumber = '+234 500 500 5005';

    final UserBirthday userBirthday =
        new UserBirthday("Someone", DateTime.now(), false, phoneNumber);
    List<UserBirthday> birthdays = [];
    birthdays.add(userBirthday);
    await _storageService.saveBirthdaysForDate(dateTime, birthdays);

    List<UserBirthday> storedBirthdays =
        await _storageService.getBirthdaysForDate(dateTime, false);
    expect(storedBirthdays.length, 1);

    await _storageService.clearAllBirthdays();

    storedBirthdays =
        await _storageService.getBirthdaysForDate(dateTime, false);

    expect(storedBirthdays.length, 0);
  });

  test("SharedPreferences set ThemeMode to dark mode", () async {
    await _storageService.saveThemeModeSetting(true);
    bool isDarkModeEnabled = await _storageService.getThemeModeSetting();
    expect(isDarkModeEnabled, true);
  });

  test(
      "SharedPreferences default contact permission status is not permanently denied",
      () async {
    bool isContactsPermissionStatusPermanentlyDenied =
        await _storageService.getIsContactPermissionPermanentlyDenied();
    expect(isContactsPermissionStatusPermanentlyDenied, false);
  });

  test(
      "SharedPreferences updateContactIdForBirthday persists the new contactId",
      () async {
    final DateTime dateTime = DateTime(2021, 6, 15);
    final UserBirthday original = UserBirthday("Alice", dateTime, false, "");
    await _storageService.saveBirthdaysForDate(dateTime, [original]);

    await _storageService.updateContactIdForBirthday(original, "contact-123");

    final stored = await _storageService.getBirthdaysForDate(dateTime, false);
    expect(stored.length, 1);
    expect(stored[0].contactId, equals("contact-123"));
  });

  test(
      "SharedPreferences updateContactIdForBirthday preserves all other fields",
      () async {
    final DateTime dateTime = DateTime(2021, 6, 15);
    final UserBirthday original = UserBirthday(
      "Alice",
      dateTime,
      true,
      "+1 555 0100",
      notificationId: 42,
    );
    await _storageService.saveBirthdaysForDate(dateTime, [original]);

    await _storageService.updateContactIdForBirthday(original, "contact-123");

    final stored = await _storageService.getBirthdaysForDate(dateTime, false);
    expect(stored[0].name, equals("Alice"));
    expect(stored[0].hasNotification, isTrue);
    expect(stored[0].phoneNumber, equals("+1 555 0100"));
    expect(stored[0].notificationId, equals(42));
    expect(stored[0].contactId, equals("contact-123"));
  });

  test(
      "SharedPreferences updateContactIdForBirthday only updates the matching entry",
      () async {
    final DateTime dateTime = DateTime(2021, 6, 15);
    final UserBirthday alice = UserBirthday("Alice", dateTime, false, "");
    final UserBirthday bob = UserBirthday("Bob", dateTime, false, "");
    await _storageService.saveBirthdaysForDate(dateTime, [alice, bob]);

    await _storageService.updateContactIdForBirthday(alice, "contact-alice");

    final stored = await _storageService.getBirthdaysForDate(dateTime, false);
    final storedAlice = stored.firstWhere((b) => b.name == "Alice");
    final storedBob = stored.firstWhere((b) => b.name == "Bob");
    expect(storedAlice.contactId, equals("contact-alice"));
    expect(storedBob.contactId, equals(""));
  });

  test(
      "SharedPreferences updateContactIdForBirthday is a no-op when entry not found",
      () async {
    final DateTime dateTime = DateTime(2021, 6, 15);
    final UserBirthday alice = UserBirthday("Alice", dateTime, false, "");
    final UserBirthday ghost = UserBirthday("Ghost", dateTime, false, "");
    await _storageService.saveBirthdaysForDate(dateTime, [alice]);

    // Should not throw
    await _storageService.updateContactIdForBirthday(ghost, "contact-ghost");

    final stored = await _storageService.getBirthdaysForDate(dateTime, false);
    expect(stored.length, 1);
    expect(stored[0].name, equals("Alice"));
  });

  test("SharedPreferences migrateContactIds flag defaults to false", () async {
    final migrated = await _storageService.getAlreadyMigratedContactIds();
    expect(migrated, isFalse);
  });

  test("SharedPreferences saveDidAlreadyMigrateContactIds persists true",
      () async {
    await _storageService.saveDidAlreadyMigrateContactIds(true);
    final migrated = await _storageService.getAlreadyMigratedContactIds();
    expect(migrated, isTrue);
  });

  test(
      "SharedPreferences saveDidAlreadyMigrateContactIds can be reset to false",
      () async {
    await _storageService.saveDidAlreadyMigrateContactIds(true);
    await _storageService.saveDidAlreadyMigrateContactIds(false);
    final migrated = await _storageService.getAlreadyMigratedContactIds();
    expect(migrated, isFalse);
  });
}
