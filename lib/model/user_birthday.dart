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

  static bool _sameDay(DateTime a, DateTime b) =>
      a.month == b.month && a.day == b.day;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserBirthday &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          _sameDay(birthdayDate, other.birthdayDate);

  @override
  int get hashCode => name.hashCode ^ birthdayDate.month ^ birthdayDate.day;

  bool equals(UserBirthday otherBirthday) {
    return this.name == otherBirthday.name &&
        _sameDay(this.birthdayDate, otherBirthday.birthdayDate);
  }

  factory UserBirthday.fromJson(Map<String, dynamic> json) {
    final parsedDate =
        DateTime.tryParse(json[userBirthdayDateKey] as String? ?? '') ??
            DateTime.now();
    // Extract name once so it can be reused for the notificationId fallback
    // without a second cast that could also throw.
    final name = json[userBirthdayNameKey] as String? ?? '';
    final hasNotification =
        json[userBirthdayHasNotificationKey] as bool? ?? false;
    final phoneNumber = json[userBirthdayPhoneNumberKey] as String? ?? '';

    return UserBirthday(
      name,
      parsedDate,
      hasNotification,
      phoneNumber,
      notificationId: json[userBirthdayNotificationIdKey] as int? ??
          _deterministicId(name, parsedDate),
    );
  }

  Map<String, dynamic> toJson() => {
        userBirthdayNameKey: name,
        userBirthdayDateKey: birthdayDate.toIso8601String(),
        userBirthdayHasNotificationKey: hasNotification,
        userBirthdayPhoneNumberKey: phoneNumber,
        userBirthdayNotificationIdKey: notificationId
      };
}
