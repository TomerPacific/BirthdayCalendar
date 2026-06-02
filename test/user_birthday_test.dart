import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserBirthday identification and hash tests', () {
    test('notificationKey should be deterministic and delimited (year-invariant)', () {
      final birthdayDate = DateTime(1990, 5, 15);
      final userBirthday = UserBirthday("John Doe", birthdayDate, false, "");
      expect(userBirthday.notificationKey, "John Doe|5|15");
    });

    test('notificationKey should be year-invariant', () {
      final firstBirthday = UserBirthday("John Doe", DateTime(1990, 5, 15), false, "");
      final sameBirthdayDifferentYear = UserBirthday("John Doe", DateTime(2023, 5, 15), false, "");
      
      expect(firstBirthday.notificationKey, "John Doe|5|15");
      expect(sameBirthdayDifferentYear.notificationKey, "John Doe|5|15");
      expect(firstBirthday.notificationId, sameBirthdayDifferentYear.notificationId);
    });

    test('notificationKey and hashes should resolve potential ambiguities', () {
      // name="a1", month=1, day=11 -> "a1|1|11"
      final firstBirthday = UserBirthday("a1", DateTime(2000, 1, 11), false, "");
      // name="a11", month=1, day=1 -> "a11|1|1"
      final secondBirthday = UserBirthday("a11", DateTime(2000, 1, 1), false, "");

      expect(firstBirthday.notificationKey, "a1|1|11");
      expect(secondBirthday.notificationKey, "a11|1|1");
      
      expect(firstBirthday.notificationId, 1707436631);
      expect(secondBirthday.notificationId, 1640337131);
    });

    test('notificationId and hashCode should match stable hash of notificationKey', () {
      final birthdayDate = DateTime(1990, 5, 15);
      final userBirthday = UserBirthday("John Doe", birthdayDate, false, "");
      // Hash of "John Doe|5|15" using the stable algorithm
      const expectedHash = 2144736322;
      
      expect(userBirthday.notificationId, expectedHash);
      expect(userBirthday.hashCode, expectedHash);
    });

    test('fromJson should reconstruct fields and notificationId correctly', () {
      final birthdayDate = DateTime(1990, 5, 15);
      final originalBirthday = UserBirthday("John Doe", birthdayDate, true, "123", notificationId: 12345);
      final json = originalBirthday.toJson();
      
      final reconstructedBirthday = UserBirthday.fromJson(json);
      
      expect(reconstructedBirthday.name, "John Doe");
      expect(reconstructedBirthday.birthdayDate, birthdayDate);
      expect(reconstructedBirthday.notificationId, 12345);
      expect(reconstructedBirthday.hashCode, reconstructedBirthday.notificationId);
      expect(reconstructedBirthday.notificationKey, originalBirthday.notificationKey);
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

    test('fromJson should use deterministic fallback for invalid dates', () {
      final json = {
        'name': 'Fallback Test',
        'birthdayDate': 'invalid-date',
        'hasNotification': false,
        'phoneNumber': ''
      };
      
      final birthday = UserBirthday.fromJson(json);
      
      expect(birthday.birthdayDate, DateTime(1970));
      // "Fallback Test|1|1" -> 1754549306
      expect(birthday.notificationId, 1754549306);
    });

    test('stable hash algorithm matches reference for simple input', () {
      // Hash of "a|1|1" -> 93326603
      final userBirthday = UserBirthday("a", DateTime(2000, 1, 1), false, "");
      expect(userBirthday.notificationId, 93326603);
    });
  });
}
