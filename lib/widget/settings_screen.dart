import 'package:birthday_calendar/service/PermissionServicePermissionHandler.dart';
import 'package:flutter/material.dart';
import 'package:birthday_calendar/service/shared_prefs.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:birthday_calendar/constants.dart';

class SettingsScreen extends StatefulWidget {
  final Function onClearNotifications;
  final Function onThemeChanged;
  final PermissionServicePermissionHandler permissionServicePermissionHandler;

  const SettingsScreen({
    required this.onClearNotifications,
    required this.onThemeChanged,
    required this.permissionServicePermissionHandler});

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  bool _isDarkModeEnabled = false;
  String versionNumber = "";
  bool _shouldImportContactsTileBeDisabled = false;

  @override
  void initState() {
    _isDarkModeEnabled = SharedPrefs().getThemeModeSetting();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
        setState(() {
          versionNumber = packageInfo.version;
        });
      });
    });

    super.initState();
  }


  void _showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text("Are You Sure?"),
      content: Text("Do you want to remove all notifications?"),
      actions: [
        TextButton(
        onPressed: () {
          SharedPrefs().clearAllNotifications()
              .then((didClearAllNotifications) =>
          {
            if (didClearAllNotifications) {
              widget.onClearNotifications()
            }
          });
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

  void _requestContactsPermission() async {
    PermissionStatus status = await widget.permissionServicePermissionHandler.requestPermissionAndGetStatus(contactsPermissionKey);
    if (status == PermissionStatus.granted) {
      //Import contacts
    } else if (status == PermissionStatus.permanentlyDenied) {
      setState(() {
        _shouldImportContactsTileBeDisabled = true;
      });
    }
  }

  void _handleImportingContacts() async {
      PermissionStatus status = await widget.permissionServicePermissionHandler.getPermissionStatus(contactsPermissionKey);
      if (status == PermissionStatus.denied) {
          _requestContactsPermission();
      } else if (status == PermissionStatus.permanentlyDenied) {
        setState(() {
          _shouldImportContactsTileBeDisabled = true;
        });
      }
  }

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
                    SharedPrefs().saveThemeModeSetting(_isDarkModeEnabled);
                    ThemeMode mode = _isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light;
                    widget.onThemeChanged(mode);
                  });
                },
              ),
             ListTile(
                  title: const Text("Import Contacts"),
                  leading: Icon(Icons.contacts,
                      color: !_shouldImportContactsTileBeDisabled ? Colors.blue : Colors.grey
                  ),
                  onTap: _handleImportingContacts,
                  enabled: !_shouldImportContactsTileBeDisabled,
              ),
              ListTile(
                  title: const Text("Clear Notifications"),
                  leading: const Icon(
                      Icons.clear,
                      color: Colors.redAccent),
                  onTap: () {
                    _showAlertDialog(context);
                  }
              ),
              Spacer(),
              new Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                          "v " + this.versionNumber
                      )
                  )
                ],
              )
            ],
          ),
    );
  }

}