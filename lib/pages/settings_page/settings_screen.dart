
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:birthday_calendar/pages/settings_page/settings_screen_manager.dart';
import 'package:birthday_calendar/service/service_locator.dart';
import 'package:birthday_calendar/widget/users_without_birthdays_dialogs.dart';

class SettingsScreen extends StatelessWidget {

  final SettingsScreenManager _settingsScreenManager = getIt<SettingsScreenManager>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
              appBar: AppBar(
                title: new Text("Settings"),
              ),
              body:
              new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ValueListenableBuilder<bool>(
                      valueListenable: _settingsScreenManager.themeChangeNotifier,
                      builder: (context, value, child) {
                        return SwitchListTile(
                          title: const Text('Dark Mode'),
                          value: value,
                          secondary:
                          new Icon(Icons.dark_mode,
                              color: value == false ? Color(0xFF642ef3) : Color.fromARGB(200, 243, 231, 106)
                          ),
                          onChanged:_settingsScreenManager.handleThemeModeSettingChange
                        );
                    }
                  ),
                  ValueListenableBuilder<bool>(valueListenable: _settingsScreenManager.importContactsNotifier, builder: (context, value, child) {
                    return ListTile(
                      title: const Text("Import Contacts"),
                      leading: Icon(Icons.contacts,
                          color: value == false ? Colors.blue : Colors.grey
                      ),
                      onTap: () {
                        _handleImportContactsButtonClicked(context);
                      },
                      enabled: !value
                    );
                  }),
                  ListTile(
                      title: const Text("Clear Notifications"),
                      leading: const Icon(
                          Icons.clear,
                          color: Colors.redAccent),
                      onTap: () {
                        _showClearBirthdaysConfirmationDialog(context);
                      }
                  ),
                  Spacer(),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ValueListenableBuilder<String>(
                          valueListenable: _settingsScreenManager.versionNotifier,
                          builder: (context, value, child) {
                            return Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                    "v " + value
                                )
                            );
                      })
                    ],
                  )
                ],
              ),
      );
  }

  void _showClearBirthdaysConfirmationDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text("Are You Sure?"),
      content: Text("Do you want to remove all notifications?"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("No"),
        ),
        TextButton(
          onPressed: () {
            _settingsScreenManager.onClearBirthdaysPressed();
            Navigator.pop(context);
          },
          child: const Text("Yes"),
        )
      ],
    );
    showDialog(context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  void _handleImportContactsButtonClicked(BuildContext context) async {
    Tuple2<PermissionStatus, List<Contact>> pair = await _settingsScreenManager.handleImportingContacts();
    if (pair.item1 == PermissionStatus.granted) {
      UsersWithoutBirthdaysDialogs assignBirthdaysToUsers = UsersWithoutBirthdaysDialogs(pair.item2);
      List<Contact> users = await assignBirthdaysToUsers.showConfirmationDialog(context);
      if (users.length > 0) {
        _gatherBirthdaysForUsers(context, users);
      }
    }
  }

  void _gatherBirthdaysForUsers(BuildContext context, List<Contact> users) async {
    for (Contact contact in users) {
      DateTime? chosenBirthDate = await showDatePicker(context: context,
          initialDate: DateTime(1970, 1, 1),
          firstDate: DateTime(1970, 1, 1),
          lastDate: DateTime.now(),
          initialEntryMode: DatePickerEntryMode.input,
          helpText: "Choose birth date for ${contact.displayName}",
          fieldLabelText: "${contact.displayName}'s birth date"
      );

      if (chosenBirthDate != null) {
        contact.birthday = chosenBirthDate;
        _settingsScreenManager.addContactToCalendar(contact);
      }
    }
  }
}