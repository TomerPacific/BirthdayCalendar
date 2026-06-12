import 'package:birthday_calendar/constants.dart';
import 'dart:math';

class UserBirthday {
  final String name;
  final DateTime birthdayDate;
  bool hasNotification;
  String phoneNumber;
  final int notificationId;

  // Generates a random positive 31-bit ID. Used only when no persisted ID
  // exists (new birthday, or legacy record without a stored notificationId).
  // Random IDs are immediately persisted to storage so they remain stable
  // across app restarts — unlike a hash, they are unique by assignment rather
  // than probabilistically unique by construction.
  static int _generateId() => Random().nextInt(0x7fffffff);

  UserBirthday(
      this.name, this.birthdayDate, this.hasNotification, this.phoneNumber,
      {int? notificationId})
      : this.notificationId = notificationId ?? _generateId();

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
    return UserBirthday(
      name,
      parsedDate,
      json[userBirthdayHasNotificationKey] as bool? ?? false,
      json[userBirthdayPhoneNumberKey] as String? ?? '',
      // If no ID is stored (legacy record), generate a fresh random one.
      // It will be persisted to storage immediately after fromJson returns.
      notificationId:
          json[userBirthdayNotificationIdKey] as int? ?? _generateId(),
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
