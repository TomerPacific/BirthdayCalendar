
import 'dart:convert';

import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:flutter/material.dart';
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

  static UserBirthday? getUserBirthdayFromPayload(String? payload) {

    if (payload == null || payload.isEmpty) {
      return null;
    }

    UserBirthday? userBirthday;
    try {
      Map<String, dynamic> json = jsonDecode(payload);
      userBirthday = UserBirthday.fromJson(json);
    } catch (e) {

    }

    return userBirthday;
  }

  static void showSnackbarWithMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message),
        ));
  }

  static int correctMonthOverflow(int month) {
    if (month == 0) {
      month = 12;
    } else if (month == 13) {
      month = 1;
    }
    return month;
  }

}