import 'dart:async';
import 'package:birthday_calendar/ClearNotificationsBloc/ClearNotificationsBloc.dart';
import 'package:birthday_calendar/ContactsPermissionStatusBloc/ContactsPermissionStatusBloc.dart';
import 'package:birthday_calendar/ThemeBloc/ThemeBloc.dart';
import 'package:birthday_calendar/VersionBloc/VersionBloc.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/service/contacts_service/contacts_service.dart';
import 'package:birthday_calendar/utils.dart';
import 'package:birthday_calendar/widget/users_without_birthdays_dialogs.dart';
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
                  unawaited(_handleImportingContacts(context));
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
                .add(ClearNotificationsRequested());
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.yes),
        )
      ],
    );
    unawaited(showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        }));
  }

  Future<void> _handleImportingContacts(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final contactsPermissionStatusBloc =
        BlocProvider.of<ContactsPermissionStatusBloc>(context);

    PermissionStatus status =
        await contactsService.getContactsPermissionStatus();

    if (!context.mounted) return;

    if (status == PermissionStatus.denied) {
      status = await contactsService.requestContactsPermission();
    }

    if (!context.mounted) return;

    if (status == PermissionStatus.permanentlyDenied) {
      await contactsService.setContactsPermissionPermanentlyDenied();
      if (!context.mounted) return;
      contactsPermissionStatusBloc
          .add(ContactsPermissionStatusEvent.PermissionPermanentlyDenied);
      return;
    }

    if (status == PermissionStatus.granted) {
      contactsPermissionStatusBloc
          .add(ContactsPermissionStatusEvent.PermissionGranted);
      List<Contact> contacts = await contactsService.fetchContacts(false);

      if (!context.mounted) return;

      if (contacts.isEmpty) {
        Utils.showSnackbarWithMessage(
            context, localizations.noContactsFoundMsg);
        return;
      }

      contacts = await contactsService.filterAlreadyImportedContacts(contacts);

      if (!context.mounted) return;

      if (contacts.isEmpty) {
        Utils.showSnackbarWithMessage(
            context, localizations.alreadyAddedContactsMsg);
        return;
      }

      await _handleAddingBirthdaysToContacts(context, contacts);
    }
  }

  Future<void> _handleAddingBirthdaysToContacts(
      BuildContext context, List<Contact> contactsWithoutBirthDates) async {
    UsersWithoutBirthdaysDialogs assignBirthdaysToUsers =
        UsersWithoutBirthdaysDialogs(contactsWithoutBirthDates);
    List<Contact> users =
        await assignBirthdaysToUsers.showConfirmationDialog(context);
    if (users.isNotEmpty) {
      if (!context.mounted) return;
      await _gatherBirthdaysForUsers(context, users);
    }
  }

  Future<void> _gatherBirthdaysForUsers(
      BuildContext context, List<Contact> users) async {
    int amountOfBirthdaysSet = 0;
    final localizations = AppLocalizations.of(context)!;

    for (Contact contact in users) {
      if (!context.mounted) return;
      DateTime? chosenBirthDate = await showDatePicker(
          context: context,
          initialDate: DateTime(1970, 1, 1),
          firstDate: DateTime(1970, 1, 1),
          lastDate: DateTime.now(),
          initialEntryMode: DatePickerEntryMode.input,
          helpText: localizations
              .helpTextChooseBirthdateForImportedContact(contact.displayName),
          fieldLabelText: localizations
              .fieldLabelTextChooseBirthdateForImportedContact(
                  contact.displayName));

      if (chosenBirthDate != null) {
        UserBirthday userBirthday = new UserBirthday(
            contact.displayName,
            chosenBirthDate,
            true,
            contact.phones.isNotEmpty ? contact.phones.first.number : "",
            contactId: contact.id);

        await contactsService.addContactToCalendar(userBirthday, localizations.notificationForBirthdayMessage(userBirthday.name));
        amountOfBirthdaysSet++;
      }
    }

    if (amountOfBirthdaysSet > 0) {
      if (!context.mounted) return;
      Utils.showSnackbarWithMessage(
          context, localizations.contactsImportedSuccessfully);
    }
  }
}
