

import 'package:birthday_calendar/service/contacts_service/bc_contacts_service.dart';
import 'package:birthday_calendar/service/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  setupServiceLocator();
  BCContactsService _bcContactsService = getIt<BCContactsService>();


  setUp(() {
    return Future(() async {
      WidgetsFlutterBinding.ensureInitialized();
    });
  });

  test("ContactsService fetch contacts", () async {
    PermissionStatus status = await _bcContactsService.requestContactsPermission();
    if (status == PermissionStatus.granted) {
      List<Contact> contacts = await _bcContactsService.fetchContacts(false);
      expect(contacts.length, 0);
    }
  });

}