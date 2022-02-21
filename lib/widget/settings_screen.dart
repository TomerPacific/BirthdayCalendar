import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:birthday_calendar/service/shared_prefs.dart';

class SettingsScreen extends StatefulWidget {
  final Function onClearNotifications;

  const SettingsScreen({required this.onClearNotifications});

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  bool _isDarkModeEnabled = false;
  bool _importContacts = false;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("Settings"),
      ),
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SwitchListTile(
              title: const Text('Dark Mode'),
              value: _isDarkModeEnabled,
              secondary:
                new Icon(Icons.dark_mode,
                  color: Color(0xFF642ef3)
                ),
            onChanged: (bool value) {
                setState(() {
                  _isDarkModeEnabled = value;
                });
              },
          ),
          CheckboxListTile(
            title: const Text("Import Contacts"),
              value: _importContacts,
              onChanged: (bool? value) {
                if (value != null) {
                  setState(() {
                    _importContacts = value;
                  });
              }
            },
            secondary: const Icon(Icons.contacts,
              color: Colors.blue
            ),
          ),
          ListTile(
            title: const Text("Clear Notifications"),
            leading: const Icon(
              Icons.clear,
              color: Colors.redAccent),
              onTap: () {
                SharedPrefs().clearAllNotifications()
                    .then((didClearAllNotifications) =>
                {
                  if (didClearAllNotifications) {
                     widget.onClearNotifications()
                  }
                });
              }
          )
        ],
      ),
    );
  }

}