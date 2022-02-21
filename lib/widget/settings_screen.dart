import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {

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
            title: const Text("Import Contacts?"),
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
          )
        ],
      ),
    );
  }

}