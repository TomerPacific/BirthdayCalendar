import 'dart:convert';
import 'package:birthday_calendar/constants.dart';

class UserBirthday {
  final String name;
  final DateTime birthdayDate;
  bool hasNotification;
  String phoneNumber;
  final int notificationId;
  final int _cachedHashCode;

  UserBirthday._internal(this.name, this.birthdayDate, this.hasNotification,
      this.phoneNumber, this.notificationId, this._cachedHashCode);

  factory UserBirthday(String name, DateTime birthdayDate, bool hasNotification,
      String phoneNumber,
      {int? notificationId}) {
    final id = notificationId ??
        _generateStableHash(_createNotificationKey(name, birthdayDate));
    return UserBirthday._internal(name, birthdayDate, hasNotification,
        phoneNumber, id, id);
  }

  void updateNotificationStatus(bool status) {
    this.hasNotification = status;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserBirthday &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          birthdayDate == other.birthdayDate &&
          notificationId == other.notificationId;

  @override
  int get hashCode => _cachedHashCode;

  bool equals(UserBirthday otherBirthday) {
    return (this.name == otherBirthday.name &&
        this.birthdayDate == otherBirthday.birthdayDate);
  }

  /// Returns a deterministic key used to identify this birthday for notifications.
  /// The key is composed of name, month, and day to ensure it remains stable
  /// across app restarts and platforms. It is year-invariant (excluding the year)
  /// to ensure that notifications for the same person on the same date remain
  /// consistent even if the recorded birth year varies.
  String get notificationKey => _createNotificationKey(name, birthdayDate);

  static String _createNotificationKey(String name, DateTime date) =>
      "$name|${date.month}|${date.day}";

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

/// Generates a deterministic 31-bit hash for a string.
/// This is used instead of [Object.hashCode] because Dart's [String.hashCode]
/// is not guaranteed to be stable across app restarts, platforms, or SDK versions.
/// Stable IDs are required for reliably scheduling and cancelling notifications.
int _generateStableHash(String string) {
  int hash = 0;
  for (int byte in utf8.encode(string)) {
    hash = (31 * hash + byte) & 0xFFFFFFFF;
  }
  return hash.toUnsigned(31);
}
