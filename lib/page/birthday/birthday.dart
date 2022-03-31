import 'package:birthday_calendar/page/birthday/birthday_manager.dart';
import 'package:flutter/material.dart';
import 'package:birthday_calendar/model/user_birthday.dart';
import '../../service/storage_service/storage_service.dart';
import '../../service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/service_locator.dart';

class BirthdayWidget extends StatefulWidget {
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
  _BirthdayWidgetState createState() => _BirthdayWidgetState();
}

class _BirthdayWidgetState extends State<BirthdayWidget> {
  bool isNotificationEnabledForPerson = false;
  StorageService _storageService = getIt<StorageService>();
  NotificationService _notificationService = getIt<NotificationService>();
  BirthdayManager _birthdayManager = new BirthdayManager();


  void updateNotificationStatusForBirthday() {
    setState(() {
      isNotificationEnabledForPerson = !isNotificationEnabledForPerson;
    });
    _storageService.updateNotificationStatusForBirthday(
        widget.birthdayOfPerson, isNotificationEnabledForPerson);
    if (!isNotificationEnabledForPerson) {
      _notificationService.cancelNotificationForBirthday(widget.birthdayOfPerson);
    } else {
      _notificationService.scheduleNotificationForBirthday(
          widget.birthdayOfPerson,
          "${widget.birthdayOfPerson.name} has an upcoming birthday!");
    }
  }

  @override
  void initState() {
    isNotificationEnabledForPerson = widget.birthdayOfPerson.hasNotification;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: _birthdayManager.getColorBasedOnPosition(widget.indexOfBirthday, "background"),
      child: Row(
        children: [
          new Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.birthdayOfPerson.name,
              textDirection: TextDirection.ltr,
              style: new TextStyle(fontSize: 20.0, color: _birthdayManager.getColorBasedOnPosition(widget.indexOfBirthday, "text")),
            ),
          ),
          new Spacer(),
          new IconButton(
              icon: Icon(
                  !isNotificationEnabledForPerson
                      ? Icons.notifications_off_outlined
                      : Icons.notifications_active_outlined,
                  color:  _birthdayManager.getColorBasedOnPosition(widget.indexOfBirthday, "icon")),
              onPressed: () {
                updateNotificationStatusForBirthday();
              }),
          new IconButton(
              icon: Icon(Icons.call, color: _birthdayManager.getColorBasedOnPosition(widget.indexOfBirthday, "icon")),
              onPressed: () {
                _birthdayManager.handleCallButtonPressed(widget.birthdayOfPerson.phoneNumber);
              }),
          new IconButton(
              icon: Icon(Icons.clear, color: _birthdayManager.getColorBasedOnPosition(widget.indexOfBirthday, "icon")),
              onPressed: widget.onDeletePressedCallback),
        ],
      ),
    );
  }
}
