import 'package:flutter/material.dart';
import 'package:birthday_calendar/pages/settings_page/settings_screen_manager.dart';
import 'package:birthday_calendar/service/service_locator.dart';

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
                              color: Color(0xFF642ef3)
                          ),
                          onChanged:_settingsScreenManager.handleThemeModeSettingChange
                        );
                    }
                  ),

                  ListTile(
                    title: const Text("Import Contacts"),
                    leading: Icon(Icons.contacts,
                        color: _settingsScreenManager.getColorForImportContactsTile()
                    ),
                    onTap: _settingsScreenManager.handleImportingContacts,
                    enabled: _settingsScreenManager.shouldImportContactsTileBeEnabled(),
                  ),
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
                      ValueListenableBuilder<String>(valueListenable: _settingsScreenManager.versionNotifier, builder: (context, value, child) {
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
            _settingsScreenManager.onClearBirthdaysPressed();
            Navigator.pop(context);
          },
          child: const Text("Yes"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("No"),
        ),
      ],
    );
    showDialog(context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }
}