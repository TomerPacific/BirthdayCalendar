import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class ContactsService {
  Future<PermissionStatus> getContactsPermissionStatus();
  Future<PermissionStatus> requestContactsPermission();
  Future<void> setContactsPermissionPermanentlyDenied();
  Future<bool> isContactsPermissionsPermanentlyDenied();
  Future<List<Contact>> filterAlreadyImportedContacts(
      List<Contact> contacts);
  Future<List<Contact>> fetchContacts(
      bool withThumbnails);
  Future<void> addContactToCalendar(
      UserBirthday contact, String notificationMessage);
}