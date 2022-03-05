
import 'dart:async';

import 'package:birthday_calendar/pages/settings_page/notifiers/ClearBirthdaysNotifier.dart';
import 'package:birthday_calendar/pages/settings_page/notifiers/ImportContactsNotifier.dart';
import 'package:birthday_calendar/pages/settings_page/notifiers/VersionNotifier.dart';
import 'package:birthday_calendar/service/permission_service/permissions_service.dart';
import 'notifiers/ThemeChangeNotifier.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:birthday_calendar/constants.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:birthday_calendar/service/service_locator.dart';
import 'package:tuple/tuple.dart';

class SettingsScreenManager {

  final PermissionsService _permissionsService = getIt<PermissionsService>();
  final StorageService _storageService = getIt<StorageService>();
  final NotificationService _notificationService = getIt<NotificationService>();
  final ThemeChangeNotifier themeChangeNotifier = ThemeChangeNotifier();
  final VersionNotifier versionNotifier = VersionNotifier();
  final ClearBirthdaysNotifier clearBirthdaysNotifier = ClearBirthdaysNotifier();
  final ImportContactsNotifier importContactsNotifier = ImportContactsNotifier();

  void onClearBirthdaysPressed() {
    clearBirthdaysNotifier.clearBirthdays();
  }

  void handleThemeModeSettingChange(bool isDarkModeEnabled) {
    themeChangeNotifier.toggleTheme();
  }

  Future<Tuple2<PermissionStatus, List<Contact>>> handleImportingContacts() async {
    PermissionStatus status = await _permissionsService.getPermissionStatus(contactsPermissionKey);
    Tuple2<PermissionStatus, List<Contact>> pair = Tuple2(status, []);
    if (status == PermissionStatus.denied) {
      pair = await _requestContactsPermission();
    } else if (status == PermissionStatus.permanentlyDenied) {
        importContactsNotifier.toggleImportContacts();
    } else if (status == PermissionStatus.granted) {
      List<Contact> contacts = await ContactsService.getContacts(withThumbnails: false);
      List<Contact> contactsWithoutBirthDates = await _addBirthdaysOfContactsAndSetNotifications(contacts);
      pair = Tuple2(status, contactsWithoutBirthDates);
    }

    return pair;
  }

  Future<Tuple2<PermissionStatus, List<Contact>>> _requestContactsPermission() async {
    PermissionStatus status = await _permissionsService.requestPermissionAndGetStatus(contactsPermissionKey);
    List<Contact> contactsWithoutBirthDates = [];
    if (status == PermissionStatus.granted) {
      List<Contact> contacts = await ContactsService.getContacts(withThumbnails: false);
      contactsWithoutBirthDates = await _addBirthdaysOfContactsAndSetNotifications(contacts);
    } else if (status == PermissionStatus.permanentlyDenied) {
      importContactsNotifier.toggleImportContacts();
    }

    return Tuple2(status, contactsWithoutBirthDates);
  }

  Future<List<Contact>> _addBirthdaysOfContactsAndSetNotifications(List<Contact> contacts) async {
    List<Contact> usersWithoutBirthdays = [];
    for (Contact person in contacts) {
      if (person.birthday == null) {
        usersWithoutBirthdays.add(person);
      } else if (person.birthday != null &&
          person.displayName != null &&
          person.phones != null) {
        addContactToCalendar(person);
      }
    }
    
    return usersWithoutBirthdays;
  }

  void addContactToCalendar(Contact contact) async {
    String phoneNumber = "";
    if (contact.phones != null && contact.phones!.length > 0) {
      phoneNumber = contact.phones!.first.value!;
    }

    UserBirthday birthday = new UserBirthday(
        contact.displayName!,
        contact.birthday!,
        false,
        phoneNumber);
    _notificationService.scheduleNotificationForBirthday(
        birthday, "${contact.displayName!} has an upcoming birthday!");
    List<UserBirthday> birthdays = await _storageService
        .getBirthdaysForDate(contact.birthday!, false);
    birthdays.add(birthday);

    _storageService.saveBirthdaysForDate(contact.birthday!, birthdays);
  }
}