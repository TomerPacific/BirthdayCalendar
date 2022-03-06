
import 'package:flutter/material.dart';
import 'package:birthday_calendar/pages/settings_page/notifiers/ClearBirthdaysNotifier.dart';
import 'package:birthday_calendar/pages/settings_page/notifiers/ImportContactsNotifier.dart';
import 'package:birthday_calendar/pages/settings_page/notifiers/VersionNotifier.dart';
import 'package:birthday_calendar/service/contacts_service/bc_contacts_service.dart';
import 'package:birthday_calendar/service/permission_service/permissions_service.dart';
import '../../widget/users_without_birthdays_dialogs.dart';
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

  void handleImportingContacts(BuildContext context) async {
    PermissionStatus status = await _permissionsService.getPermissionStatus(contactsPermissionKey);

    if (status == PermissionStatus.permanentlyDenied) {
      importContactsNotifier.toggleImportContacts();
      return;
    }

    if (status == PermissionStatus.granted) {
      _processContacts(context);
      return;
    }

    if (status == PermissionStatus.denied) {
      _handleRequestingContactsPermission(context);
    }
  }

  void _handleRequestingContactsPermission(BuildContext context) async {
    PermissionStatus status = await _permissionsService.requestPermissionAndGetStatus(contactsPermissionKey);

    if (status == PermissionStatus.permanentlyDenied) {
      importContactsNotifier.toggleImportContacts();
      return;
    }

    if (status == PermissionStatus.granted) {
      _processContacts(context);
    }
  }

  void _processContacts(BuildContext context) async {
    List<Contact> contacts = await _bcContactsService.fetchContacts(false);
    List<Contact> contactsWithoutBirthDates = await _bcContactsService.gatherContactsWithoutBirthdays(contacts);
    _bcContactsService.addContactsWithBirthdays(contacts);
    UsersWithoutBirthdaysDialogs assignBirthdaysToUsers = UsersWithoutBirthdaysDialogs(contactsWithoutBirthDates);
    List<Contact> users = await assignBirthdaysToUsers.showConfirmationDialog(context);
    if (users.length > 0) {
      _gatherBirthdaysForUsers(context, users);
    }
  }

  void addContactToCalendar(Contact contact) {
    _bcContactsService.addContactToCalendar(contact);
  }

  void _gatherBirthdaysForUsers(BuildContext context, List<Contact> users) async {
    for (Contact contact in users) {
      DateTime? chosenBirthDate = await showDatePicker(context: context,
          initialDate: DateTime(1970, 1, 1),
          firstDate: DateTime(1970, 1, 1),
          lastDate: DateTime.now(),
          initialEntryMode: DatePickerEntryMode.input,
          helpText: "Choose birth date for ${contact.displayName}",
          fieldLabelText: "${contact.displayName}'s birth date"
      );

      if (chosenBirthDate != null) {
        contact.birthday = chosenBirthDate;
        addContactToCalendar(contact);
      }
    }
  }
}