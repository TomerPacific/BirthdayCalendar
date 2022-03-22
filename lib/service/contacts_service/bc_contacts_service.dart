import 'package:contacts_service/contacts_service.dart';

abstract class BCContactsService {
  Future<List<Contact>> fetchContacts(bool withThumbnails);
  Future<List<Contact>> gatherContactsWithoutBirthdays(List<Contact> contacts);
  void addContactsWithBirthdays(List<Contact> contacts);
  void addContactToCalendar(Contact contact);
}