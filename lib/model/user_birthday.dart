import 'package:birthday_calendar/constants.dart';

class UserBirthday {
  final String name;
  final DateTime birthdayDate;
  bool hasNotification;
  final String phoneNumber;

  UserBirthday(this.name, this.birthdayDate, this.hasNotification, this.phoneNumber);

  void updateNotificationStatus(bool status) {
    this.hasNotification = status;
  }

  bool equals(UserBirthday otherBirthday) {
    return (this.name == otherBirthday.name &&
        this.birthdayDate == otherBirthday.birthdayDate);
  }

  UserBirthday.fromJson(Map<String, dynamic> json)
      : name = json[userBirthdayNameKey],
        birthdayDate = DateTime.tryParse(json[userBirthdayDateKey]) ?? DateTime.now(),
        hasNotification = json[userBirthdayHasNotificationKey],
        phoneNumber = json[userBirthdayPhoneNumberKey];

  Map<String, dynamic> toJson() => {
        userBirthdayNameKey: name,
        userBirthdayDateKey: birthdayDate.toIso8601String(),
        userBirthdayHasNotificationKey: hasNotification,
        userBirthdayPhoneNumberKey: phoneNumber
      };
}
