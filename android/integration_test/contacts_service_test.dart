

import 'package:birthday_calendar/service/contacts_service/bc_contacts_service.dart';
import 'package:birthday_calendar/service/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  BCContactsService _bcContactsService = getIt<BCContactsService>();


  setUp(() {
    return Future(() async {
      WidgetsFlutterBinding.ensureInitialized();
    });
  });

  testWidgets('verify amount of contacts', (WidgetTester tester) async {
    // tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    // const MethodChannel('flutter.baseflow.com/permissions/methods'),
    //     (MethodCall methodCall) async => PermissionStatus.granted);
  List<Contact> contacts = await _bcContactsService.fetchContacts(false);
  expect(contacts.length, 0);
  });
  //   test("ContactsService fetch contacts", () async {
  //   //PermissionStatus status = await _bcContactsService.requestContactsPermission();
  //   //if (status == PermissionStatus.granted) {
  //   tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
  //       const MethodChannel('flutter.baseflow.com/permissions/methods'),
  //           (MethodCall methodCall) async => PermissionStatus.granted);
  //     List<Contact> contacts = await _bcContactsService.fetchContacts(false);
  //     expect(contacts.length, 0);
  //  // }
  // });

}