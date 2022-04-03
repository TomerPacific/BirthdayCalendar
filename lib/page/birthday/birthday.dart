import 'package:birthday_calendar/page/birthday/birthday_manager.dart';
import 'package:flutter/material.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:provider/provider.dart';

class BirthdayWidget extends StatelessWidget {
  final UserBirthday birthdayOfPerson;
  final VoidCallback onDeletePressedCallback;
  final int indexOfBirthday;

  BirthdayWidget(
      {required Key key ,
      required this.birthdayOfPerson,
      required this.onDeletePressedCallback,
      required this.indexOfBirthday})
      : super(key: key);


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create:  (context) => BirthdayManager(birthdayOfPerson),
        builder: (context, provider) {
          return Container(
            height: 40,
            color: Provider.of<BirthdayManager>(context, listen: false).getColorBasedOnPosition(indexOfBirthday, ElementType.background),
            child: Row(
              children: [
                new Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    birthdayOfPerson.name,
                    textDirection: TextDirection.ltr,
                    style: new TextStyle(fontSize: 20.0, color: Provider.of<BirthdayManager>(context, listen: false).getColorBasedOnPosition(indexOfBirthday, ElementType.text)),
                  ),
                ),
                new Spacer(),
                new Consumer<BirthdayManager>(
                  builder: (context, data, child) =>
                  new IconButton(
                      icon: Icon(
                          !data.userBirthday.hasNotification
                              ? Icons.notifications_off_outlined
                              : Icons.notifications_active_outlined,
                          color:  Provider.of<BirthdayManager>(context, listen: false).getColorBasedOnPosition(indexOfBirthday, ElementType.icon)),
                      onPressed: () {
                        Provider.of<BirthdayManager>(context, listen: false).updateNotificationStatusForBirthday();
                      }),
                ),
                new IconButton(
                    icon: Icon(Icons.call, color: Provider.of<BirthdayManager>(context, listen: false).getColorBasedOnPosition(indexOfBirthday, ElementType.icon)),
                    onPressed: () {
                      Provider.of<BirthdayManager>(context, listen: false).handleCallButtonPressed(birthdayOfPerson.phoneNumber);
                    }),
                new IconButton(
                    icon: Icon(Icons.clear, color: Provider.of<BirthdayManager>(context, listen: false).getColorBasedOnPosition(indexOfBirthday, ElementType.icon)),
                    onPressed: onDeletePressedCallback),
              ],
            ),
          );
        },
    );
  }
}
