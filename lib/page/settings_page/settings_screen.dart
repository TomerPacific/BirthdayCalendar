import 'package:birthday_calendar/ClearNotificationsBloc/ClearNotificationsBloc.dart';
import 'package:birthday_calendar/ContactsPermissionStatusBloc/ContactsPermissionStatusBloc.dart';
import 'package:birthday_calendar/ThemeBloc/ThemeBloc.dart';
import 'package:birthday_calendar/VersionBloc/VersionBloc.dart';
import 'package:birthday_calendar/service/contacts_service/contacts_service.dart';
import 'package:birthday_calendar/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:birthday_calendar/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({
    required this.contactsService,
  });

  final ContactsService contactsService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text(AppLocalizations.of(context)!.settings),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SwitchListTile(
              title: Text(AppLocalizations.of(context)!.darkMode),
              value: context.read<ThemeBloc>().state == ThemeMode.dark
                  ? true
                  : false,
              secondary: new Icon(Icons.dark_mode,
                  color: context.read<ThemeBloc>().state == ThemeMode.dark
                      ? Color.fromARGB(200, 243, 231, 106)
                      : Color(0xFF642ef3)),
              onChanged: (bool newValue) {
                ThemeEvent event =
                    context.read<ThemeBloc>().state == ThemeMode.dark
                        ? ThemeEvent.toggleLight
                        : ThemeEvent.toggleDark;
                BlocProvider.of<ThemeBloc>(context).add(event);
              }),
          BlocBuilder<ContactsPermissionStatusBloc, PermissionStatus>(
              builder: (context, state) {
            return ListTile(
                title: Text(AppLocalizations.of(context)!.importContacts),
                leading: Icon(Icons.contacts, color: Colors.blue),
                onTap: () {
                  _handleImportingContacts(context);
                },
                enabled: state.isPermanentlyDenied ? false : true);
          }),
          ListTile(
              title: Text(AppLocalizations.of(context)!.clearNotifications),
              leading: const Icon(Icons.clear, color: Colors.redAccent),
              onTap: () {
                _showClearBirthdaysConfirmationDialog(context);
              }),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Align(
                  alignment: Alignment.bottomRight,
                  child: BlocBuilder<VersionBloc, String>(
                      builder: (context, state) {
                    return Text("v $state");
                  }))
            ],
          )
        ],
      ),
    );
  }

  void _showClearBirthdaysConfirmationDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context)!.clearNotificationsAlertTitle),
      content: Text(
          AppLocalizations.of(context)!.clearNotificationsAlertDescription),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.no),
        ),
        TextButton(
          onPressed: () {
            BlocProvider.of<ClearNotificationsBloc>(context)
                .add(ClearNotificationsEvent.ClearedNotifications);
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.yes),
        )
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  void _handleImportingContacts(BuildContext context) async {
    PermissionStatus status =
        await contactsService.getContactsPermissionStatus(context);

    if (status == PermissionStatus.denied) {
      status = await contactsService.requestContactsPermission(context);
    }

    if (status == PermissionStatus.permanentlyDenied) {
      contactsService.setContactsPermissionPermanentlyDenied();
      BlocProvider.of<ContactsPermissionStatusBloc>(context)
          .add(ContactsPermissionStatusEvent.PermissionPermanentlyDenied);
      return;
    }

    if (status == PermissionStatus.granted) {
      BlocProvider.of<ContactsPermissionStatusBloc>(context)
          .add(ContactsPermissionStatusEvent.PermissionGranted);
      List<Contact> contacts = await contactsService.fetchContacts(false);

      if (contacts.isEmpty) {
        Utils.showSnackbarWithMessage(
            context, AppLocalizations.of(context)!.noContactsFoundMsg);
        return;
      }

      contacts = await contactsService.filterAlreadyImportedContacts(contacts);

      if (contacts.isEmpty) {
        Utils.showSnackbarWithMessage(
            context, AppLocalizations.of(context)!.alreadyAddedContactsMsg);
        return;
      }

      contactsService.handleAddingBirthdaysToContacts(context, contacts);
    }
  }
}
