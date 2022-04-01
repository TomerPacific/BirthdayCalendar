import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/service_locator.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BirthdayManager extends ChangeNotifier {

  StorageService _storageService = getIt<StorageService>();
  NotificationService _notificationService = getIt<NotificationService>();
  UserBirthday _userBirthday = new UserBirthday("", DateTime.now(), false, "");

  UserBirthday get userBirthday => _userBirthday;

  BirthdayManager(UserBirthday birthday) {
    _userBirthday = birthday;
  }

  Color getColorBasedOnPosition(int index, String element) {
    if (element == "background") {
      return index % 2 == 0 ? Colors.indigoAccent : Colors.white24;
    }

    return index % 2 == 0 ? Colors.white : Colors.black;
  }

  void handleCallButtonPressed(String phoneNumber) async {
    String phoneUrl = 'tel://' + phoneNumber;
    if (await canLaunch(phoneUrl)) {
      launch(phoneUrl);
    }
  }

  void updateNotificationStatusForBirthday() {
    bool isNotificationEnabledForPerson = _userBirthday.hasNotification;
    isNotificationEnabledForPerson = !isNotificationEnabledForPerson;
    userBirthday.hasNotification = isNotificationEnabledForPerson;
    _storageService.updateNotificationStatusForBirthday(_userBirthday, isNotificationEnabledForPerson);
    if (!isNotificationEnabledForPerson) {
      _notificationService.cancelNotificationForBirthday(_userBirthday);
    } else {
      _notificationService.scheduleNotificationForBirthday(
          _userBirthday,
          "${_userBirthday.name} has an upcoming birthday!");
    }
    notifyListeners();
  }

}