import 'package:birthday_calendar/constants.dart';

class UserBirthday {
  final String name;
  final DateTime birthdayDate;
  bool hasNotification;
  String phoneNumber;
  final int notificationId;

  static int _deterministicId(String name, DateTime date) {
    final key = '$name:${date.month}:${date.day}';
    // Jenkins one-at-a-time hash — stable, no dart:crypto dependency
    int h = 0;
    for (final unit in key.codeUnits) {
      h = (h + unit) & 0x7fffffff;
      h = (h + (h << 10)) & 0x7fffffff;
      h ^= (h >> 6);
    }
    h = (h + (h << 3)) & 0x7fffffff;
    h ^= (h >> 11);
    h = (h + (h << 15)) & 0x7fffffff;
    return h;
  }

  UserBirthday(
      this.name, this.birthdayDate, this.hasNotification, this.phoneNumber,
      {int? notificationId})
      : this.notificationId =
      notificationId ?? _deterministicId(name, birthdayDate);

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
  int get hashCode => name.hashCode ^ birthdayDate.hashCode;

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
            _deterministicId(
              json[userBirthdayNameKey] as String,
              DateTime.tryParse(json[userBirthdayDateKey]) ?? DateTime.now(),
            );

  Map<String, dynamic> toJson() => {
    userBirthdayNameKey: name,
    userBirthdayDateKey: birthdayDate.toIso8601String(),
    userBirthdayHasNotificationKey: hasNotification,
    userBirthdayPhoneNumberKey: phoneNumber,
    userBirthdayNotificationIdKey: notificationId
  };
}