import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserBirthday identification and hash tests', () {
    test('notificationKey should be deterministic and delimited', () {
      final date = DateTime(1990, 5, 15);
      final ub = UserBirthday("John Doe", date, false, "");
      expect(ub.notificationKey, "John Doe|5|15");
    });

    test('notificationKey should be year-invariant', () {
      final ub1 = UserBirthday("John Doe", DateTime(1990, 5, 15), false, "");
      final ub2 = UserBirthday("John Doe", DateTime(2023, 5, 15), false, "");
      expect(ub1.notificationKey, "John Doe|5|15");
      expect(ub2.notificationKey, "John Doe|5|15");
    });

    test('notificationKey and hashes should resolve potential ambiguities', () {
      // name="a1", month=1, day=11 vs name="a11", month=1, day=1
      final ub1 = UserBirthday("a1", DateTime(2000, 1, 11), false, "");
      final ub2 = UserBirthday("a11", DateTime(2000, 1, 1), false, "");

      expect(ub1.notificationKey, "a1|1|11");
      expect(ub2.notificationKey, "a11|1|1");
      
      // Checking exact stable hash values instead of simple inequality
      expect(ub1.notificationId, 1707436631);
      expect(ub2.notificationId, 1640337131);
      expect(ub1.hashCode, 1707436631);
      expect(ub2.hashCode, 1640337131);

      // name="a", month=11, day=1 vs name="a1", month=1, day=1
      final ub3 = UserBirthday("a", DateTime(2000, 11, 1), false, "");
      final ub4 = UserBirthday("a1", DateTime(2000, 1, 1), false, "");

      expect(ub3.notificationKey, "a|11|1");
      expect(ub4.notificationKey, "a1|1|1");
      
      expect(ub3.notificationId, 745571344);
      expect(ub4.notificationId, 678541594);
    });

    test('notificationId and hashCode should match stable hash of notificationKey', () {
      final date = DateTime(1990, 5, 15);
      final ub = UserBirthday("John Doe", date, false, "");
      // Hash of "John Doe|5|15" using the stable algorithm
      const expectedHash = 2144736322;
      
      expect(ub.notificationId, expectedHash);
      expect(ub.hashCode, expectedHash);
    });

    test('fromJson should reconstruct fields and notificationId correctly', () {
      final date = DateTime(1990, 5, 15);
      final ub1 = UserBirthday("John Doe", date, true, "123");
      final json = ub1.toJson();
      
      final ub2 = UserBirthday.fromJson(json);
      
      expect(ub2.name, "John Doe");
      expect(ub2.birthdayDate, date);
      expect(ub2.notificationId, ub1.notificationId);
      expect(ub2.notificationKey, ub1.notificationKey);
    });

    test('stable hash algorithm matches reference for simple input', () {
      // Hash of "a|1|1" -> 93326603
      final ub = UserBirthday("a", DateTime(2000, 1, 1), false, "");
      expect(ub.notificationId, 93326603);
    });
  });
}
