
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';

class UsersWithoutBirthdaysDialogs {

  UsersWithoutBirthdaysDialogs(this.usersWithoutBirthdays);

  final List<Contact> usersWithoutBirthdays;

  void showConfirmationDialog(BuildContext context) {
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
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return showUsersDialog(context);
                  });
            },
            child: const Text("Proceed"),
          ),
        ]
    );
    showDialog(context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  Widget showUsersDialog(BuildContext context) {
    List<bool> _usersSelectedToAddBirthdaysFor = List.filled(usersWithoutBirthdays.length, false);
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
                                setState(() => _usersSelectedToAddBirthdaysFor[index] = value);
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
                        onPressed: () {
                          Navigator.pop(context);
                        },
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

}