import 'package:birthday_calendar/constants.dart';
import 'package:birthday_calendar/service/contacts_service/contacts_service.dart';
import 'package:birthday_calendar/service/permission_service/permissions_service.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactsServiceImpl extends ContactsService {
  ContactsServiceImpl(
      {required this.storageService,
      required this.notificationService,
      required this.permissionsService});

  final StorageService storageService;
  final NotificationService notificationService;
  final PermissionsService permissionsService;

  @override
  Future<PermissionStatus> getContactsPermissionStatus() async {
    return await permissionsService.getPermissionStatus(contactsPermissionKey);
  }

  @override
  Future<PermissionStatus> requestContactsPermission() async {
    return await permissionsService
        .requestPermissionAndGetStatus(contactsPermissionKey);
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
