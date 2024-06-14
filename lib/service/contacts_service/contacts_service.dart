import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class ContactsService {
  Future<PermissionStatus> getContactsPermissionStatus(BuildContext context);
  Future<PermissionStatus> requestContactsPermission(BuildContext context);
  void setContactsPermissionPermanentlyDenied();
  Future<bool> isContactsPermissionsPermanentlyDenied();
    Future<List<Contact>> filterAlreadyImportedContacts(List<Contact> contacts);
  void handleAddingBirthdaysToContacts(BuildContext context, List<Contact> contactsWithoutBirthDates);
  Future<List<Contact>> fetchContacts(bool withThumbnails);
  void addContactToCalendar(UserBirthday contact);
}