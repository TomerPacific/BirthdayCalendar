import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:birthday_calendar/l10n/app_localizations.dart';

class UsersWithoutBirthdaysDialogs {
  UsersWithoutBirthdaysDialogs(this.usersWithoutBirthdays);

  final List<Contact> usersWithoutBirthdays;

  Future<List<Contact>> showConfirmationDialog(BuildContext context) async {
    AlertDialog alert = AlertDialog(
        title: Text(AppLocalizations.of(context)!.addBirthdaysToContactsAlertDialogTitle),
        content: Text(
            AppLocalizations.of(context)!.addBirthdaysToContactsAlertDialogDescription),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.no),
          ),
          TextButton(
            onPressed: () async {
              var result = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return _showUsersDialog(context);
                  });
              Navigator.pop(context, result);
            },
            child: Text(AppLocalizations.of(context)!.proceed),
          ),
        ]);
    var result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });

    return result == null ? [] : result;
  }

  Widget _showUsersDialog(BuildContext context) {
    List<bool> _usersSelectedToAddBirthdaysFor =
        List.filled(usersWithoutBirthdays.length, false);
    bool _haveAnyContactsBeenSelected = false;

    AlertDialog alert = AlertDialog(
        title: Text(AppLocalizations.of(context)!.peopleWithoutBirthdaysAlertDialogTitle),
        content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: ListView(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: usersWithoutBirthdays.length,
                    itemBuilder: (BuildContext context, int index) {
                      return CheckboxListTile(
                          title: Text(usersWithoutBirthdays[index].displayName),
                          value: _usersSelectedToAddBirthdaysFor[index],
                          onChanged: (bool? value) {
                            if (value != null) {
                              setState(() {
                                _usersSelectedToAddBirthdaysFor[index] = value;
                                _haveAnyContactsBeenSelected =
                                    _haveUsersBeenSelected(
                                        _usersSelectedToAddBirthdaysFor);
                              });
                            }
                          });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        child: Text(AppLocalizations.of(context)!.cancel),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                          child: Text(AppLocalizations.of(context)!.ok),
                          onPressed: !_haveAnyContactsBeenSelected
                              ? null
                              : () => _collectUsersToAddBirthdaysTo(
                                  context, _usersSelectedToAddBirthdaysFor)),
                    ],
                  )
                ],
              ));
        }));

    return alert;
  }

  bool _haveUsersBeenSelected(List<bool> usersSelectedToAddBirthdaysFor) {
    return usersSelectedToAddBirthdaysFor
        .firstWhere((element) => element == true, orElse: () => false);
  }

  void _collectUsersToAddBirthdaysTo(
      BuildContext context, List<bool> usersSelectedToAddBirthdaysFor) {
    List<Contact> usersToSetBirthDatesTo = [];
    usersWithoutBirthdays.asMap().forEach((index, value) {
      if (usersSelectedToAddBirthdaysFor[index]) {
        usersToSetBirthDatesTo.add(value);
      }
    });
    Navigator.pop(context, usersToSetBirthDatesTo);
  }
}
