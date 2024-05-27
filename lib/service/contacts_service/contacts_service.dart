import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

abstract class ContactsService {
  Future<List<Contact>> fetchContacts(bool withThumbnails);
  void addContactToCalendar(UserBirthday contact);
}