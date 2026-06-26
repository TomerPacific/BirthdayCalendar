import 'package:birthday_calendar/constants.dart';
import 'package:birthday_calendar/service/contacts_service/contacts_service.dart';
import 'package:birthday_calendar/service/permission_service/permissions_service.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/utils.dart';
import 'package:birthday_calendar/widget/users_without_birthdays_dialogs.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:birthday_calendar/l10n/app_localizations.dart';

class ContactsServiceImpl extends ContactsService {
  ContactsServiceImpl(
      {required this.storageService,
      required this.notificationService,
      required this.permissionsService});

  final StorageService storageService;
  final NotificationService notificationService;
  final PermissionsService permissionsService;

  @override
  Future<PermissionStatus> getContactsPermissionStatus(
      BuildContext context) async {
    return await permissionsService.getPermissionStatus(contactsPermissionKey);
  }

  @override
  Future<PermissionStatus> requestContactsPermission(
      BuildContext context) async {
    return await permissionsService
        .requestPermissionAndGetStatus(contactsPermissionKey, context: context);
  }

  @override
  Future<void> setContactsPermissionPermanentlyDenied() async {
    await storageService.saveIsContactsPermissionPermanentlyDenied(true);
  }

  @override
  Future<bool> isContactsPermissionsPermanentlyDenied() async {
    return storageService.getIsContactPermissionPermanentlyDenied();
  }

  @override
  Future<List<Contact>> filterAlreadyImportedContacts(
      List<Contact> contacts) async {
    return Utils.filterAlreadyImportedContacts(storageService, contacts);
  }

  @override
  Future<void> handleAddingBirthdaysToContacts(
      BuildContext context, List<Contact> contactsWithoutBirthDates) async {
    UsersWithoutBirthdaysDialogs assignBirthdaysToUsers =
        UsersWithoutBirthdaysDialogs(contactsWithoutBirthDates);
    List<Contact> users =
        await assignBirthdaysToUsers.showConfirmationDialog(context);
    if (users.isNotEmpty) {
      if (!context.mounted) return;
      await _gatherBirthdaysForUsers(context, users);
    }
  }

  Future<void> _gatherBirthdaysForUsers(
      BuildContext context, List<Contact> users) async {
    int amountOfBirthdaysSet = 0;
    final localizations = AppLocalizations.of(context)!;

    for (Contact contact in users) {
      if (!context.mounted) return;
      DateTime? chosenBirthDate = await showDatePicker(
          context: context,
          initialDate: DateTime(1970, 1, 1),
          firstDate: DateTime(1970, 1, 1),
          lastDate: DateTime.now(),
          initialEntryMode: DatePickerEntryMode.input,
          helpText: localizations
              .helpTextChooseBirthdateForImportedContact(contact.displayName),
          fieldLabelText: localizations
              .fieldLabelTextChooseBirthdateForImportedContact(
                  contact.displayName));

      if (chosenBirthDate != null) {
        UserBirthday userBirthday = new UserBirthday(
            contact.displayName,
            chosenBirthDate,
            true,
            contact.phones.isNotEmpty ? contact.phones.first.number : "",
            contactId: contact.id);

        await addContactToCalendar(userBirthday, localizations.notificationForBirthdayMessage(userBirthday.name));
        amountOfBirthdaysSet++;
      }
    }

    if (amountOfBirthdaysSet > 0) {
      if (!context.mounted) return;
      Utils.showSnackbarWithMessage(
          context, localizations.contactsImportedSuccessfully);
    }
  }

  @override
  Future<List<Contact>> fetchContacts(bool withThumbnails) async {
    return await FlutterContacts.getContacts(withProperties: true);
  }

  @override
  Future<void> addContactToCalendar(UserBirthday contact, String notificationMessage) async {
    List<UserBirthday> birthdays =
        await storageService.getBirthdaysForDate(contact.birthdayDate, false);

    UserBirthday? alreadyExists =
        birthdays.firstWhereOrNull((element) => element == contact);

    if (alreadyExists != null) {
      return;
    }

    await notificationService.scheduleNotificationForBirthday(
        contact,
        notificationMessage);

    birthdays.add(contact);

    await storageService.saveBirthdaysForDate(contact.birthdayDate, birthdays);
  }
}
