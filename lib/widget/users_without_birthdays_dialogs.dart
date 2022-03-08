
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';

class UsersWithoutBirthdaysDialogs {

  UsersWithoutBirthdaysDialogs(this.usersWithoutBirthdays);

  final List<Contact> usersWithoutBirthdays;

  Future<List<Contact>> showConfirmationDialog(BuildContext context) async {
    AlertDialog alert = AlertDialog(
        title: Text("Add Birthdays For People"),
        content: Text(
            "There are contacts on your phone who do not have a birth date. "
                "Would you like to manually add birth dates for them?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("No"),
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
            child: const Text("Proceed"),
          ),
        ]
    );
    var result = await showDialog(context: context,
        builder: (BuildContext context) {
          return alert;
        });

    return result == null ? [] : result;
  }

  Widget _showUsersDialog(BuildContext context) {
    List<bool> _usersSelectedToAddBirthdaysFor = List.filled(usersWithoutBirthdays.length, false);
    bool _haveAnyContactsBeenSelected = false;
    
    AlertDialog alert = AlertDialog(
        title: Text('People Without Birthdays'),
        content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return Container(
              height: 300.0,
              width: 300.0,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: usersWithoutBirthdays.length,
                      itemBuilder: (BuildContext context, int index) {
                        return CheckboxListTile(
                            title: Text(usersWithoutBirthdays[index].displayName!),
                            value: _usersSelectedToAddBirthdaysFor[index],
                            onChanged: (bool? value) {
                              if (value != null) {
                                setState(() {
                                  _usersSelectedToAddBirthdaysFor[index] = value;
                                  _haveAnyContactsBeenSelected = _haveUsersBeenSelected(_usersSelectedToAddBirthdaysFor);
                                });
                              }
                            }
                        );
                      },
                    ),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: Text("Continue"),
                        onPressed:
                          !_haveAnyContactsBeenSelected ?
                          null : () => _collectUsersToAddBirthdaysTo(context, _usersSelectedToAddBirthdaysFor)
                      ),
                    ],
                  )
                ],
              )
            );
          }
        )
    );

    return alert;
  }

  bool _haveUsersBeenSelected(List<bool> usersSelectedToAddBirthdaysFor) {
    return usersSelectedToAddBirthdaysFor.firstWhere(
            (element) => element == true, orElse: () => false);
  }

  void _collectUsersToAddBirthdaysTo(BuildContext context, List<bool> usersSelectedToAddBirthdaysFor) {
    List<Contact> usersToSetBirthDatesTo = [];
    usersWithoutBirthdays.asMap().forEach((index, value) {
      if (usersSelectedToAddBirthdaysFor[index]) {
        usersToSetBirthDatesTo.add(value);
      }
    });
    Navigator.pop(context, usersToSetBirthDatesTo);
  }
}