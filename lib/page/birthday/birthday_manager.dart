import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum ElementType { background, icon, text }

class BirthdayManager extends ChangeNotifier {
  late StorageService _storageService;
  late NotificationService _notificationService;
  UserBirthday _userBirthday = new UserBirthday("", DateTime.now(), false, "");

  UserBirthday get userBirthday => _userBirthday;

  BirthdayManager(UserBirthday birthday, StorageService storageService,
      NotificationService notificationService) {
    _storageService = storageService;
    _notificationService = notificationService;
    _userBirthday = birthday;
  }

  void handleCallButtonPressed(String phoneNumber) async {
    Uri phoneUri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(phoneUri)) {
      launchUrl(phoneUri);
    } else {
      print("Cannot call $phoneUri");
    }
  }

  void updateNotificationStatusForBirthday() {
    bool isNotificationEnabledForPerson = _userBirthday.hasNotification;
    isNotificationEnabledForPerson = !isNotificationEnabledForPerson;
    userBirthday.hasNotification = isNotificationEnabledForPerson;
    _storageService.updateNotificationStatusForBirthday(
        _userBirthday, isNotificationEnabledForPerson);
    if (!isNotificationEnabledForPerson) {
      _notificationService.cancelNotificationForBirthday(_userBirthday);
    } else {
      _notificationService.scheduleNotificationForBirthday(
          _userBirthday, "${_userBirthday.name} has an upcoming birthday!");
    }
    notifyListeners();
  }
}
