import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  bool _isDarkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("Settings"),
      ),
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
          )
        ],
      ),
    );
  }

}