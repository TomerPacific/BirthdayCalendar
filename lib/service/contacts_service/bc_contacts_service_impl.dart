import 'package:contacts_service/contacts_service.dart';
import 'package:birthday_calendar/service/contacts_service/bc_contacts_service.dart';
import 'package:birthday_calendar/service/service_locator.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:collection/collection.dart';

class BCContactsServiceImpl extends BCContactsService {

  final StorageService _storageService = getIt<StorageService>();
  final NotificationService _notificationService = getIt<NotificationService>();

  @override
  Future<List<Contact>> fetchContacts(bool withThumbnails) async {
    return await ContactsService.getContacts(withThumbnails: false);
  }

  Future<List<Contact>> gatherContactsWithoutBirthdays(List<Contact> contacts) async {
    List<Contact> usersWithoutBirthdays = contacts.where((element) => element.birthday == null).toList();
    return usersWithoutBirthdays;
  }

  void addContactsWithBirthdays(List<Contact> contacts) {
    for (Contact person in contacts) {
      if (person.birthday != null &&
          person.displayName != null &&
          person.phones != null) {
        addContactToCalendar(person);
      }
    }
  }

  void addContactToCalendar(Contact contact) async {
    String phoneNumber = "";
    List<UserBirthday> birthdays = await _storageService.getBirthdaysForDate(contact.birthday!, false);
    String contactName = contact.displayName!;

    UserBirthday? birthdayWithSameName = birthdays.firstWhereOrNull((element) => element.name == contactName);


    if (birthdayWithSameName != null) {
      return;
    }

    if (contact.phones != null && contact.phones!.length > 0) {
      phoneNumber = contact.phones!.first.value!;
    }

    UserBirthday birthday = new UserBirthday(
        contact.displayName!,
        contact.birthday!,
        true,
        phoneNumber);
    _notificationService.scheduleNotificationForBirthday(
        birthday, "${contact.displayName!} has an upcoming birthday!");

    birthdays.add(birthday);

    _storageService.saveBirthdaysForDate(contact.birthday!, birthdays);
  }

}