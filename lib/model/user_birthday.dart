import 'package:birthday_calendar/constants.dart';

class UserBirthday {
  final String name;
  final DateTime birthdayDate;
  bool hasNotification;
  String phoneNumber;
  final int notificationId;

  UserBirthday(
      this.name, this.birthdayDate, this.hasNotification, this.phoneNumber,
      {int? notificationId})
      : this.notificationId = notificationId ??
            "$name|${birthdayDate.month}|${birthdayDate.day}"
                .hashCode
                .toUnsigned(31);

  void updateNotificationStatus(bool status) {
    this.hasNotification = status;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserBirthday &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          birthdayDate == other.birthdayDate;

  @override
  int get hashCode => "$name|${birthdayDate.month}|${birthdayDate.day}".hashCode;

  bool equals(UserBirthday otherBirthday) {
    return (this.name == otherBirthday.name &&
        this.birthdayDate == otherBirthday.birthdayDate);
  }

  factory UserBirthday.fromJson(Map<String, dynamic> json) {
    return UserBirthday(
        json[userBirthdayNameKey],
        DateTime.tryParse(json[userBirthdayDateKey]) ?? DateTime.now(),
        json[userBirthdayHasNotificationKey],
        json[userBirthdayPhoneNumberKey],
        notificationId: json[userBirthdayNotificationIdKey]);
  }

  Map<String, dynamic> toJson() => {
        userBirthdayNameKey: name,
        userBirthdayDateKey: birthdayDate.toIso8601String(),
        userBirthdayHasNotificationKey: hasNotification,
        userBirthdayPhoneNumberKey: phoneNumber,
        userBirthdayNotificationIdKey: notificationId
      };
}
