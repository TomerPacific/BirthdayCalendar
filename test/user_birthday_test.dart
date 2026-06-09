import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

void main() {
  group('UserBirthday identification and hash tests', () {
    test('notificationKey should be deterministic and delimited including year', () {
      final birthdayDate = DateTime(1990, 5, 15);
      final userBirthday = UserBirthday("John Doe", birthdayDate, false, "");
      expect(userBirthday.notificationKey, "John Doe|1990|5|15");
    });

    test('notificationKey should be unique for same name/day but different year', () {
      final firstBirthday = UserBirthday("John Doe", DateTime(1990, 5, 15), false, "");
      final sameBirthdayDifferentYear = UserBirthday("John Doe", DateTime(1995, 5, 15), false, "");
      
      expect(firstBirthday.notificationKey, "John Doe|1990|5|15");
      expect(sameBirthdayDifferentYear.notificationKey, "John Doe|1995|5|15");
      expect(firstBirthday.notificationId, isNot(sameBirthdayDifferentYear.notificationId));
    });

    test('notificationKey and hashes should resolve potential ambiguities', () {
      // name="a1", month=1, day=11 -> "a1|2000|1|11"
      final firstBirthday = UserBirthday("a1", DateTime(2000, 1, 11), false, "");
      // name="a11", month=1, day=1 -> "a11|2000|1|1"
      final secondBirthday = UserBirthday("a11", DateTime(2000, 1, 1), false, "");

      expect(firstBirthday.notificationKey, "a1|2000|1|11");
      expect(secondBirthday.notificationKey, "a11|2000|1|1");
      
      expect(firstBirthday.notificationId, 1899887933);
      expect(secondBirthday.notificationId, 121001539);
    });

    test('notificationId should match stable hash of notificationKey', () {
      final birthdayDate = DateTime(1990, 5, 15);
      final userBirthday = UserBirthday("John Doe", birthdayDate, false, "");
      // Hash of "John Doe|1990|5|15" using the stable algorithm
      const expectedHash = 739031889;
      
      expect(userBirthday.notificationId, expectedHash);
    });

    test('fromJson should reconstruct fields and notificationId correctly', () {
      final birthdayDate = DateTime(1990, 5, 15);
      final originalBirthday = UserBirthday("John Doe", birthdayDate, true, "123", notificationId: 12345);
      final json = originalBirthday.toJson();
      
      final reconstructedBirthday = UserBirthday.fromJson(json);
      
      expect(reconstructedBirthday.name, "John Doe");
      expect(reconstructedBirthday.birthdayDate, birthdayDate);
      expect(reconstructedBirthday.notificationId, 12345);
      expect(reconstructedBirthday.notificationKey, originalBirthday.notificationKey);
    });

    test('fromJson should use deterministic fallback for invalid dates', () {
      final json = {
        'name': 'Fallback Test',
        'birthdayDate': 'invalid-date',
        'hasNotification': false,
        'phoneNumber': ''
      };
      
      final birthday = UserBirthday.fromJson(json);
      
      expect(birthday.birthdayDate, DateTime(1970));
      // "Fallback Test|1970|1|1" -> 470640407
      expect(birthday.notificationId, 470640407);
    });

    test('stable hash algorithm matches reference for simple input', () {
      // Hash of "a|2000|1|1" -> 1793436707
      final userBirthday = UserBirthday("a", DateTime(2000, 1, 1), false, "");
      expect(userBirthday.notificationId, 1793436707);
    });

    test('operator == should identify same birthday correctly', () {
      final birthdayDate = DateTime(1990, 5, 15);
      final userBirthday1 = UserBirthday("John Doe", birthdayDate, false, "");
      final userBirthday2 = UserBirthday("John Doe", birthdayDate, false, "");
      
      expect(userBirthday1 == userBirthday2, isTrue);
    });

    test('operator == should fail if notificationId differs', () {
      final birthdayDate = DateTime(1990, 5, 15);
      final userBirthday1 = UserBirthday("John Doe", birthdayDate, false, "", notificationId: 1);
      final userBirthday2 = UserBirthday("John Doe", birthdayDate, false, "", notificationId: 2);
      
      expect(userBirthday1 == userBirthday2, isFalse);
    });

    test('copyWith should preserve notificationId if identity is unchanged', () {
      final birthdayDate = DateTime(1990, 5, 15);
      final original = UserBirthday("John Doe", birthdayDate, false, "");
      final updated = original.copyWith(hasNotification: true);
      
      expect(updated.name, original.name);
      expect(updated.birthdayDate, original.birthdayDate);
      expect(updated.hasNotification, true);
      expect(updated.notificationId, original.notificationId);
    });

    test('copyWith should recalculate notificationId if name changes', () {
      final birthdayDate = DateTime(1990, 5, 15);
      final original = UserBirthday("John Doe", birthdayDate, false, "");
      final updated = original.copyWith(name: "Jane Doe");
      
      expect(updated.name, "Jane Doe");
      expect(updated.notificationId, isNot(original.notificationId));
      expect(updated.notificationId, _generateStableHash("Jane Doe|1990|5|15"));
    });

    test('copyWith should recalculate notificationId if date changes', () {
      final originalDate = DateTime(1990, 5, 15);
      final newDate = DateTime(1995, 5, 15);
      final original = UserBirthday("John Doe", originalDate, false, "");
      final updated = original.copyWith(birthdayDate: newDate);
      
      expect(updated.birthdayDate, newDate);
      expect(updated.notificationId, isNot(original.notificationId));
      expect(updated.notificationId, _generateStableHash("John Doe|1995|5|15"));
    });

    test('copyWith should respect explicitly provided notificationId even if identity changes', () {
      final birthdayDate = DateTime(1990, 5, 15);
      final original = UserBirthday("John Doe", birthdayDate, false, "");
      final updated = original.copyWith(name: "Jane Doe", notificationId: 999);
      
      expect(updated.name, "Jane Doe");
      expect(updated.notificationId, 999);
    });
  });
}

int _generateStableHash(String string) {
  int hash = 0;
  for (int byte in utf8.encode(string)) {
    hash = (31 * hash + byte) & 0xFFFFFFFF;
  }
  return hash.toUnsigned(31);
}
