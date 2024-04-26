import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class BCContactsService {
  Future<List<Contact>> fetchContacts(bool withThumbnails);
  void addContactToCalendar(UserBirthday contact);
  Future<PermissionStatus> requestContactsPermission();
}