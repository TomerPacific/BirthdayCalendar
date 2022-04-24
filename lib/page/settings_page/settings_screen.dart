
import 'package:flutter/material.dart';
import 'package:birthday_calendar/page/settings_page/settings_screen_manager.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
              appBar: AppBar(
                title: new Text("Settings"),
              ),
              body:
                  WillPopScope(
                    onWillPop: () async {
                      Navigator.pop(context, Provider.of<SettingsScreenManager>(context, listen: false).didClearNotifications);
                      return false;
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Consumer<SettingsScreenManager>(
                            builder: (context, notifier, child) {
                              return  SwitchListTile(
                                  title: const Text('Dark Mode'),
                                  value: notifier.themeMode == ThemeMode.light ? false : true,
                                  secondary:
                                  new Icon(
                                      Icons.dark_mode,
                                      color: notifier.themeMode == ThemeMode.light ? Color(0xFF642ef3) : Color.fromARGB(200, 243, 231, 106)
                                  ),
                                  onChanged:notifier.handleThemeModeSettingChange
                              );
                            }
                        ),
                       Consumer<SettingsScreenManager>(
                           builder: (context, notifier, child) {
                          return ListTile(
                              title: const Text("Import Contacts"),
                              leading: Icon(Icons.contacts,
                                  color: !notifier.isContactsPermissionPermanentlyDenied ? Colors.blue : Colors.grey
                              ),
                              onTap: () {
                                Provider.of<SettingsScreenManager>(context, listen: false).handleImportingContacts(context);
                              },
                              enabled: !notifier.isContactsPermissionPermanentlyDenied
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Consumer<SettingsScreenManager>(
                                builder: (context, notifier, child) {
                                  return Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                          "v " + notifier.version
                                      )
                                  );
                                }
                            )
                          ],
                        )
                      ],
                    ),
                  )
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
            Provider.of<SettingsScreenManager>(context, listen: false).onClearBirthdaysPressed();
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
}