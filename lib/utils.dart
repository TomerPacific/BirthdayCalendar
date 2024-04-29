
import 'dart:convert';

import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:flutter_contacts/contact.dart';

import 'model/user_birthday.dart';

class Utils {

  static Future<List<Contact>> filterAlreadyImportedContacts(
      StorageService _storageService,
      List<Contact> contacts) async {
    List<UserBirthday> allStoredBirthdays = await _storageService.getAllBirthdays();
    List<String> names = allStoredBirthdays.map((e) => e.name).toList();
    List<Contact> filtered = contacts.where((contact) => !names.contains(contact.displayName)).toList();
    return filtered;
  }

  static UserBirthday getUserBirthdayFromPayload(String payload) {
    Map<String, dynamic> json = jsonDecode(payload);
    UserBirthday userBirthday = UserBirthday.fromJson(json);
    return userBirthday;
  }

}