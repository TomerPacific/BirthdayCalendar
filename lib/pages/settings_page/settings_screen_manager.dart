
import 'package:birthday_calendar/pages/settings_page/notifiers/ClearBirthdaysNotifier.dart';
import 'package:birthday_calendar/pages/settings_page/notifiers/ImportContactsNotifier.dart';
import 'package:birthday_calendar/pages/settings_page/notifiers/VersionNotifier.dart';
import 'package:birthday_calendar/service/permission_service/permissions_service.dart';
import 'notifiers/ThemeChangeNotifier.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:birthday_calendar/constants.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:birthday_calendar/service/service_locator.dart';

class SettingsScreenManager extends ChangeNotifier {

  List<bool> usersSelectedToAddBirthdaysFor = [];
  PermissionsService _permissionsService = getIt<PermissionsService>();
  StorageService _storageService = getIt<StorageService>();
  NotificationService _notificationService = getIt<NotificationService>();
  final ThemeChangeNotifier themeChangeNotifier = ThemeChangeNotifier();
  final VersionNotifier versionNotifier = VersionNotifier();
  final ClearBirthdaysNotifier clearBirthdaysNotifier = ClearBirthdaysNotifier();
  final ImportContactsNotifier importContactsNotifier = ImportContactsNotifier();

  MaterialColor getColorForImportContactsTile() {
    return !importContactsNotifier.value? Colors.blue : Colors.grey;
  }

  List<bool> usersWithNoBirthdates() {
    return usersSelectedToAddBirthdaysFor;
  }

  void onClearBirthdaysPressed() {
    clearBirthdaysNotifier.clearBirthdays();
  }

  void handleThemeModeSettingChange(bool isDarkModeEnabled) {
    themeChangeNotifier.toggleTheme();
  }

  void handleImportingContacts() async {
    PermissionStatus status = await _permissionsService.getPermissionStatus(contactsPermissionKey);
    if (status == PermissionStatus.denied) {
      _requestContactsPermission();
    } else if (status == PermissionStatus.permanentlyDenied) {
        importContactsNotifier.toggleImportContacts();
    } else if (status == PermissionStatus.granted) {
      _addBirthdaysOfContactsAndSetNotifications();
    }
  }

  void _requestContactsPermission() async {
    PermissionStatus status = await _permissionsService.requestPermissionAndGetStatus(contactsPermissionKey);
    if (status == PermissionStatus.granted) {
      _addBirthdaysOfContactsAndSetNotifications();
    } else if (status == PermissionStatus.permanentlyDenied) {
      importContactsNotifier.toggleImportContacts();
    }
  }

  void _addBirthdaysOfContactsAndSetNotifications() async {
    List<Contact> contacts = await ContactsService.getContacts(
        withThumbnails: false);
    List<Contact> usersWithoutBirthdays = [];
    for (Contact person in contacts) {
      if (person.birthday == null) {
        usersWithoutBirthdays.add(person);
      } else if (person.birthday != null &&
          person.displayName != null &&
          person.phones != null) {
        Item phoneNumber = person.phones!.first;
        UserBirthday birthday = new UserBirthday(
            person.displayName!, person.birthday!, false, phoneNumber.value!);
        _notificationService.scheduleNotificationForBirthday(
            birthday, "${person.displayName!} has an upcoming birthday!");
        List<UserBirthday> birthdays = await _storageService
            .getBirthdaysForDate(person.birthday!);
        birthdays.add(birthday);
        _storageService.saveBirthdaysForDate(person.birthday!, birthdays);
      }
    }

    if (usersWithoutBirthdays.length > 0) {
      _presentDialogToEnterBirthdayForUser(usersWithoutBirthdays);
    }
  }

  void _presentDialogToEnterBirthdayForUser(List<Contact> usersWithoutBirthdays) async {

  }

  Widget setupAlertDialogContainer(List<Contact> usersWithoutBirthdays) {
    return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return Container(
          height: 300.0,
          width: 300.0,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: usersWithoutBirthdays.length,
                  itemBuilder: (BuildContext context, int index) {
                    return CheckboxListTile(
                        title: Text(usersWithoutBirthdays[index].displayName!),
                        value: usersSelectedToAddBirthdaysFor[index],
                        onChanged: (bool? value) {
                          if (value != null) {
                              usersSelectedToAddBirthdaysFor[index] = value;
                          }
                        }
                    );
                  },
                ),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child: Text("Continue"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              )
            ],
          )
      );
    });
  }

}