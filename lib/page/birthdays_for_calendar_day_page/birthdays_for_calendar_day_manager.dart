
import 'dart:collection';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:birthday_calendar/widget/add_birthday_form.dart';

class BirthdaysForCalendarDayManager extends ChangeNotifier {

  late NotificationService notificationService;
  late StorageService storageService;
  final List<UserBirthday> _currentBirthdays = [];
  DateTime date = DateTime.now();

  UnmodifiableListView<UserBirthday> get birthdays => UnmodifiableListView(_currentBirthdays);

  BirthdaysForCalendarDayManager(
      List<UserBirthday> birthdays,
      DateTime dateTime,
      NotificationService notificationService,
      StorageService storageService) {
      this.notificationService = notificationService;
      this.storageService = storageService;
      _currentBirthdays.addAll(birthdays);
      date = dateTime;
  }

  void _handleUserInput(UserBirthday userBirthday) {
    _addBirthdayToList(userBirthday);
    notificationService.scheduleNotificationForBirthday(userBirthday, "${userBirthday.name} has an upcoming birthday!");
  }

  void _addBirthdayToList(UserBirthday userBirthday) {
    _currentBirthdays.add(userBirthday);

    List<UserBirthday> birthdaysMatchingDate = _currentBirthdays.where((element) => element.birthdayDate == userBirthday.birthdayDate).toList();
    storageService.saveBirthdaysForDate(date, birthdaysMatchingDate);
    notifyListeners();
  }

  void removeBirthdayFromList(UserBirthday birthdayToRemove) async {
    _currentBirthdays.remove(birthdayToRemove);

    List<UserBirthday> birthdaysForDateDeleted = await storageService.getBirthdaysForDate(birthdayToRemove.birthdayDate, false);

    List<UserBirthday> filtered = birthdaysForDateDeleted.where((element) => !element.equals(birthdayToRemove)).toList();

    storageService.saveBirthdaysForDate(birthdayToRemove.birthdayDate, filtered);
    notifyListeners();
  }

  void handleAddBirthdayBtnPressed(BuildContext context, DateTime dateOfDay, StorageService storageService) async {
    var result = await showDialog(context: context,
        builder: (_) => AddBirthdayForm(
            dateOfDay: dateOfDay,
            storageService: storageService));
    if (result != null) {
      _handleUserInput(result);
    }
  }

}