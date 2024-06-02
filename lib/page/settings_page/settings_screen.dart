import 'package:birthday_calendar/ClearNotificationsBloc/ClearNotificationsBloc.dart';
import 'package:birthday_calendar/ContactsPermissionStatusBloc/ContactsPermissionStatusBloc.dart';
import 'package:birthday_calendar/ThemeBloc/ThemeBloc.dart';
import 'package:birthday_calendar/VersionBloc/VersionBloc.dart';
import 'package:birthday_calendar/constants.dart';
import 'package:birthday_calendar/service/contacts_service/contacts_service.dart';
import 'package:birthday_calendar/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class SettingsScreen extends StatelessWidget {

  SettingsScreen({
    required this.contactsService,
  });

  final ContactsService contactsService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
              appBar: AppBar(
                title: new Text("Settings"),
              ),
              body: Column(
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
                          BlocBuilder<ContactsPermissionStatusBloc, PermissionStatus>(
                              builder: (context, state) {
                                return ListTile(
                                    title: const Text("Import Contacts"),
                                    leading: Icon(Icons.contacts,
                                        color: Colors.blue
                                    ),
                                    onTap: () {
                                      _handleImportingContacts(context);
                                    },
                                    enabled: state.isPermanentlyDenied ? false : true
                                );
                              }
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
                                      child: BlocBuilder<VersionBloc, String>(
                                        builder: (context, state) {
                                         return  Text(
                                             "v ${state}"
                                         );
                                        }
                                      )
                                  )
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
            BlocProvider.of<ClearNotificationsBloc>(context).add(ClearNotificationsEvent.ClearedNotifications);
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

  void _handleImportingContacts(BuildContext context) async {
    PermissionStatus status = await contactsService.getContactsPermissionStatus(context);

    if (status == PermissionStatus.denied) {
      status = await contactsService.requestContactsPermission(context);
    }


    if (status == PermissionStatus.permanentlyDenied) {
      contactsService.setContactsPermissionPermanentlyDenied();
      BlocProvider.of<ContactsPermissionStatusBloc>(context).add(ContactsPermissionStatusEvent.PermissionPermanentlyDenied);
      return;
    }

    if (status == PermissionStatus.granted) {
      BlocProvider.of<ContactsPermissionStatusBloc>(context).add(ContactsPermissionStatusEvent.PermissionGranted);
      List<Contact> contacts = await contactsService.fetchContacts(false);

      if (contacts.isEmpty) {
        Utils.showSnackbarWithMessage(context, noContactsFoundMsg);
        return;
      }

      contacts = await contactsService.filterAlreadyImportedContacts(contacts);

      if (contacts.isEmpty) {
        Utils.showSnackbarWithMessage(context, alreadyAddedContactsMsg);
        return;
      }

      contactsService.handleAddingBirthdaysToContacts(context, contacts);
    }
  }
}