import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:permission_handler/permission_handler.dart';

abstract class ContactsService {
  Future<PermissionStatus> getContactsPermissionStatus();
  Future<PermissionStatus> requestContactsPermission();
  Future<bool> shouldShowContactsRationale();
  Future<void> setContactsPermissionPermanentlyDenied();
  Future<bool> isContactsPermissionsPermanentlyDenied();
  Future<List<fc.Contact>> filterAlreadyImportedContacts(List<fc.Contact> contacts);
  Future<List<fc.Contact>> fetchContacts(bool withThumbnails);
  Future<void> addContactToCalendar(
      UserBirthday contact, String notificationMessage);
}
