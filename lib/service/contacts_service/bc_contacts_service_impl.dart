import 'package:birthday_calendar/service/contacts_service/bc_contacts_service.dart';
import 'package:birthday_calendar/service/service_locator.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:collection/collection.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class BCContactsServiceImpl extends BCContactsService {

  final StorageService _storageService = getIt<StorageService>();
  final NotificationService _notificationService = getIt<NotificationService>();

  @override
  Future<List<Contact>> fetchContacts(bool withThumbnails) async {
    return await FlutterContacts.getContacts();
  }

  void addContactToCalendar(UserBirthday contact) async {
    List<UserBirthday> birthdays = await _storageService.getBirthdaysForDate(contact.birthdayDate, false);
    String contactName = contact.name;

    UserBirthday? birthdayWithSameName = birthdays.firstWhereOrNull((element) => element.name == contactName);


    if (birthdayWithSameName != null) {
      return;
    }

    _notificationService.scheduleNotificationForBirthday(
        contact, "${contact.name} has an upcoming birthday!");

    birthdays.add(contact);

    _storageService.saveBirthdaysForDate(contact.birthdayDate, birthdays);
  }

}