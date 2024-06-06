import 'package:birthday_calendar/page/birthday/birthday_manager.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:provider/provider.dart';

class BirthdayWidget extends StatelessWidget {
  final UserBirthday birthdayOfPerson;
  final VoidCallback onDeletePressedCallback;
  final int indexOfBirthday;
  final NotificationService notificationService;
  final StorageService storageService;

  BirthdayWidget(
      {required Key key,
      required this.birthdayOfPerson,
      required this.onDeletePressedCallback,
      required this.indexOfBirthday,
      required this.notificationService,
      required this.storageService})
      : super(key: key);


  Color _getColorBasedOnPosition(int index, ElementType type) {
    if (type == ElementType.background) {
      return index % 2 == 0 ? Colors.indigoAccent : Colors.white24;
    }

    return index % 2 == 0 ? Colors.white : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BirthdayManager(
          birthdayOfPerson, storageService, notificationService),
      builder: (context, provider) {
        return Container(
          height: 40,
          color: _getColorBasedOnPosition(indexOfBirthday, ElementType.background),
          child: Row(
            children: [
              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  birthdayOfPerson.name,
                  textDirection: TextDirection.ltr,
                  style: new TextStyle(
                      fontSize: 20.0,
                      color: _getColorBasedOnPosition(indexOfBirthday, ElementType.text)),
                ),
              ),
              new Spacer(),
              new Consumer<BirthdayManager>(
                builder: (context, data, child) => new IconButton(
                    icon: Icon(
                        !data.userBirthday.hasNotification
                            ? Icons.notifications_off_outlined
                            : Icons.notifications_active_outlined,
                        color: _getColorBasedOnPosition(indexOfBirthday, ElementType.icon)),
                    onPressed: () {
                      Provider.of<BirthdayManager>(context, listen: false)
                          .updateNotificationStatusForBirthday();
                    }),
              ),
              if (birthdayOfPerson.phoneNumber.isNotEmpty) ...[
                new IconButton(
                    icon: Icon(Icons.call,
                        color: _getColorBasedOnPosition(indexOfBirthday, ElementType.icon)),
                    onPressed: () {
                      Provider.of<BirthdayManager>(context, listen: false)
                          .handleCallButtonPressed(
                              birthdayOfPerson.phoneNumber);
                    })
              ],
              new IconButton(
                  icon: Icon(Icons.clear,
                      color: _getColorBasedOnPosition(indexOfBirthday, ElementType.icon)),
                  onPressed: onDeletePressedCallback),
            ],
          ),
        );
      },
    );
  }
}
