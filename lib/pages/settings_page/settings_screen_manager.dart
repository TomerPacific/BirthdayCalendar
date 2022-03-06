
import 'dart:async';
import 'package:tuple/tuple.dart';
import 'package:birthday_calendar/pages/settings_page/notifiers/ClearBirthdaysNotifier.dart';
import 'package:birthday_calendar/pages/settings_page/notifiers/ImportContactsNotifier.dart';
import 'package:birthday_calendar/pages/settings_page/notifiers/VersionNotifier.dart';
import 'package:birthday_calendar/service/contacts_service/bc_contacts_service.dart';
import 'package:birthday_calendar/service/permission_service/permissions_service.dart';
import 'notifiers/ThemeChangeNotifier.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:birthday_calendar/constants.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:birthday_calendar/service/service_locator.dart';


class SettingsScreenManager {

  final PermissionsService _permissionsService = getIt<PermissionsService>();
  final BCContactsService _bcContactsService = getIt<BCContactsService>();
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
      List<Contact> contacts = await _bcContactsService.fetchContacts(false);
      List<Contact> contactsWithoutBirthDates = await _bcContactsService.gatherContactsWithoutBirthdays(contacts);
      _bcContactsService.addContactsWithBirthdays(contacts);
      pair = Tuple2(status, contactsWithoutBirthDates);
    }

    return pair;
  }

  Future<Tuple2<PermissionStatus, List<Contact>>> _requestContactsPermission() async {
    PermissionStatus status = await _permissionsService.requestPermissionAndGetStatus(contactsPermissionKey);
    List<Contact> contactsWithoutBirthDates = [];
    if (status == PermissionStatus.granted) {
      List<Contact> contacts = await _bcContactsService.fetchContacts(false);
      contactsWithoutBirthDates = await _bcContactsService.gatherContactsWithoutBirthdays(contacts);
      _bcContactsService.addContactsWithBirthdays(contacts);
    } else if (status == PermissionStatus.permanentlyDenied) {
      importContactsNotifier.toggleImportContacts();
    }

    return Tuple2(status, contactsWithoutBirthDates);
  }

  void addContactToCalendar(Contact contact) {
    _bcContactsService.addContactToCalendar(contact);
  }
}