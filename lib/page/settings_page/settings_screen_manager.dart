
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:birthday_calendar/service/contacts_service/bc_contacts_service.dart';
import 'package:birthday_calendar/service/permission_service/permissions_service.dart';
import 'package:birthday_calendar/service/snackbar_service/SnackbarService.dart';
import 'package:birthday_calendar/widget/users_without_birthdays_dialogs.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:birthday_calendar/constants.dart';
import 'package:birthday_calendar/service/service_locator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:birthday_calendar/utils.dart';

class SettingsScreenManager extends ChangeNotifier {

  final PermissionsService _permissionsService = getIt<PermissionsService>();
  final BCContactsService _bcContactsService = getIt<BCContactsService>();
  final SnackbarService _snackbarService = getIt<SnackbarService>();
  StorageService _storageService = getIt<StorageService>();

  ThemeMode _themeMode = ThemeMode.light;
  String _version = "";
  bool _didClearNotifications = false;
  bool _isContactsPermissionPermanentlyDenied = false;

  get themeMode => _themeMode;
  get version => _version;
  get didClearNotifications => _didClearNotifications;
  get isContactsPermissionPermanentlyDenied => _isContactsPermissionPermanentlyDenied;

  SettingsScreenManager() {
    _gatherDataFromStorage();
    _getVersionInfo();
  }

  void _gatherDataFromStorage() async {
    bool isDarkModeEnabled = await _storageService.getThemeModeSetting();
    _themeMode = isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light;
    _isContactsPermissionPermanentlyDenied = await _storageService.getIsContactPermissionPermanentlyDenied();
    notifyListeners();
  }

  void _getVersionInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _version = packageInfo.version;
    notifyListeners();
  }

  void onClearBirthdaysPressed() async {
    _storageService.clearAllBirthdays();
    _didClearNotifications = true;
  }

  void setOnClearBirthdaysFlag(bool state) {
    _didClearNotifications = state;
  }

  void handleThemeModeSettingChange(bool isDarkModeEnabled) {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _storageService.saveThemeModeSetting(isDarkModeEnabled);
    notifyListeners();
  }

  void handleImportingContacts(BuildContext context) async {
    PermissionStatus status = await _permissionsService.getPermissionStatus(contactsPermissionKey);

    if (status == PermissionStatus.permanentlyDenied) {
      _isContactsPermissionPermanentlyDenied = !_isContactsPermissionPermanentlyDenied;
      _storageService.saveIsContactsPermissionPermanentlyDenied(_isContactsPermissionPermanentlyDenied);
      notifyListeners();
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
      _isContactsPermissionPermanentlyDenied = !_isContactsPermissionPermanentlyDenied;
      _storageService.saveIsContactsPermissionPermanentlyDenied(_isContactsPermissionPermanentlyDenied);
      notifyListeners();
      return;
    }

    if (status == PermissionStatus.granted) {
      _processContacts(context);
    }
  }

  void _processContacts(BuildContext context) async {
    List<Contact> contacts = await _bcContactsService.fetchContacts(false);

    if (contacts.length == 0) {
      _snackbarService.showSnackbarWithMessage(context, noContactsFoundMsg);
      return;
    }

    contacts = await Utils.filterAlreadyImportedContacts(_storageService, contacts);

    if (contacts.length == 0) {
      _snackbarService.showSnackbarWithMessage(context, alreadyAddedContactsMsg);
      return;
    }

    _handleAddingBirthdaysToContacts(context, contacts);
  }



  void addContactToCalendar(UserBirthday contact) {
    _bcContactsService.addContactToCalendar(contact);
  }

  void _handleAddingBirthdaysToContacts(BuildContext context, List<Contact> contactsWithoutBirthDates) async {
    UsersWithoutBirthdaysDialogs assignBirthdaysToUsers = UsersWithoutBirthdaysDialogs(contactsWithoutBirthDates);
    List<Contact> users = await assignBirthdaysToUsers.showConfirmationDialog(context);
    if (users.length > 0) {
      _gatherBirthdaysForUsers(context, users);
    }
  }

  void _gatherBirthdaysForUsers(BuildContext context, List<Contact> users) async {

    int amountOfBirthdaysSet = 0;

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
        UserBirthday userBirthday = new UserBirthday(contact.displayName,
            chosenBirthDate,
            true,
            contact.phones.length > 0 ? contact.phones.first.number : "");

        addContactToCalendar(userBirthday);
        amountOfBirthdaysSet++;
      }
    }

    if (amountOfBirthdaysSet > 0) {
      _snackbarService.showSnackbarWithMessage(context, contactsImportedSuccessfullyMsg);
    }
  }
}