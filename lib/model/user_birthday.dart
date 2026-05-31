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
            (name + birthdayDate.month.toString() + birthdayDate.day.toString())
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
  int get hashCode =>
      (name + birthdayDate.month.toString() + birthdayDate.day.toString())
          .hashCode;

  bool equals(UserBirthday otherBirthday) {
    return (this.name == otherBirthday.name &&
        this.birthdayDate == otherBirthday.birthdayDate);
  }

  UserBirthday.fromJson(Map<String, dynamic> json)
      : name = json[userBirthdayNameKey],
        birthdayDate =
            DateTime.tryParse(json[userBirthdayDateKey]) ?? DateTime.now(),
        hasNotification = json[userBirthdayHasNotificationKey],
        phoneNumber = json[userBirthdayPhoneNumberKey],
        notificationId = json[userBirthdayNotificationIdKey] ??
            (json[userBirthdayNameKey] +
                    (DateTime.tryParse(json[userBirthdayDateKey]) ??
                            DateTime.now())
                        .month
                        .toString() +
                    (DateTime.tryParse(json[userBirthdayDateKey]) ??
                            DateTime.now())
                        .day
                        .toString())
                .hashCode
                .toUnsigned(31);

  Map<String, dynamic> toJson() => {
        userBirthdayNameKey: name,
        userBirthdayDateKey: birthdayDate.toIso8601String(),
        userBirthdayHasNotificationKey: hasNotification,
        userBirthdayPhoneNumberKey: phoneNumber,
        userBirthdayNotificationIdKey: notificationId
      };
}
