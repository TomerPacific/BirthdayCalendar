
import 'package:birthday_calendar/ThemeBloc/ThemeBloc.dart';
import 'package:flutter/material.dart';
import 'package:birthday_calendar/page/settings_page/settings_screen_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
              appBar: AppBar(
                title: new Text("Settings"),
              ),
              body:
                  PopScope(
                    onPopInvoked: (bool didPop) {
                      if (didPop) {
                        return;
                      }

                      Navigator.pop(context, Provider.of<SettingsScreenManager>(context, listen: false).didClearNotifications);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                              SwitchListTile(
                                  title: const Text('Dark Mode'),
                                  value: context.read<ThemeBloc>().state == ThemeMode.dark ?
                                  true :
                                  false,
                                  secondary:
                                  new Icon(
                                      Icons.dark_mode,
                                      color: context.read<ThemeBloc>().state == ThemeMode.dark ?
                                      Color.fromARGB(200, 243, 231, 106) :
                                      Color(0xFF642ef3)
                                  ),
                                  onChanged: (bool newValue) {
                                    ThemeEvent event = context.read<ThemeBloc>().state == ThemeMode.dark ?
                                    ThemeEvent.toggleLight :
                                    ThemeEvent.toggleDark;
                                    BlocProvider.of<ThemeBloc>(context).add(event);
                                  }
                              ),
                      ListTile(
                              title: const Text("Import Contacts"),
                              leading: Icon(Icons.contacts,
                                  color: Colors.blue
                              ),
                              onTap: () {
                                Provider.of<SettingsScreenManager>(context, listen: false).handleImportingContacts(context);
                              },
                              enabled: true
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                                Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                          "v "
                                      )
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