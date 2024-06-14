import 'package:birthday_calendar/UserNotificationStatusBloc/UserNotificationStatusBloc.dart';
import 'package:birthday_calendar/constants.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:birthday_calendar/utils.dart';
import 'package:flutter/material.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

enum ElementType { background, icon, text }

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

  void _handleCallButtonPressed(
      BuildContext context, String phoneNumber) async {
    Uri phoneUri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(phoneUri)) {
      launchUrl(phoneUri);
    } else {
      Utils.showSnackbarWithMessage(context, unableToMakeCallMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  color: _getColorBasedOnPosition(
                      indexOfBirthday, ElementType.text)),
            ),
          ),
          new Spacer(),
          BlocProvider(
              create: (context) => UserNotificationStatusBloc(
                  storageService, notificationService),
              child: BlocBuilder<UserNotificationStatusBloc, bool>(
                  builder: (context, state) {
                return new IconButton(
                    icon: Icon(
                        !birthdayOfPerson.hasNotification
                            ? Icons.notifications_off_outlined
                            : Icons.notifications_active_outlined,
                        color: _getColorBasedOnPosition(
                            indexOfBirthday, ElementType.icon)),
                    onPressed: () {
                      BlocProvider.of<UserNotificationStatusBloc>(context).add(
                          new UserNotificationStatusEvent(
                              userBirthday: birthdayOfPerson,
                              hasNotification:
                                  birthdayOfPerson.hasNotification));
                    });
              })),
          if (birthdayOfPerson.phoneNumber.isNotEmpty) ...[
            new IconButton(
                icon: Icon(Icons.call,
                    color: _getColorBasedOnPosition(
                        indexOfBirthday, ElementType.icon)),
                onPressed: () {
                  _handleCallButtonPressed(
                      context, birthdayOfPerson.phoneNumber);
                })
          ],
          new IconButton(
              icon: Icon(Icons.clear,
                  color: _getColorBasedOnPosition(
                      indexOfBirthday, ElementType.icon)),
              onPressed: onDeletePressedCallback),
        ],
      ),
    );
  }
}
