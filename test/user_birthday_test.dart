import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserBirthday notificationId tests', () {
    test('notificationId should be stable across instances with same name and date', () {
      final date = DateTime(1990, 5, 15);
      final ub1 = UserBirthday("John Doe", date, false, "");
      final ub2 = UserBirthday("John Doe", date, false, "");

      expect(ub1.notificationId, ub2.notificationId);
    });

    test('notificationId should be different for different names', () {
      final date = DateTime(1990, 5, 15);
      final ub1 = UserBirthday("John Doe", date, false, "");
      final ub2 = UserBirthday("Jane Doe", date, false, "");

      expect(ub1.notificationId, isNot(ub2.notificationId));
    });

    test('notificationId should be different for different months', () {
      final ub1 = UserBirthday("John Doe", DateTime(1990, 5, 15), false, "");
      final ub2 = UserBirthday("John Doe", DateTime(1990, 6, 15), false, "");

      expect(ub1.notificationId, isNot(ub2.notificationId));
    });

    test('notificationId should be different for different days', () {
      final ub1 = UserBirthday("John Doe", DateTime(1990, 5, 15), false, "");
      final ub2 = UserBirthday("John Doe", DateTime(1990, 5, 16), false, "");

      expect(ub1.notificationId, isNot(ub2.notificationId));
    });

    test('notificationId should be same regardless of year', () {
      final ub1 = UserBirthday("John Doe", DateTime(1990, 5, 15), false, "");
      final ub2 = UserBirthday("John Doe", DateTime(2023, 5, 15), false, "");

      expect(ub1.notificationId, ub2.notificationId);
    });

    test('fromJson should reconstruct notificationId correctly', () {
      final date = DateTime(1990, 5, 15);
      final ub1 = UserBirthday("John Doe", date, true, "123");
      final json = ub1.toJson();
      
      final ub2 = UserBirthday.fromJson(json);
      
      expect(ub2.notificationId, ub1.notificationId);
      expect(ub2.name, ub1.name);
      expect(ub2.birthdayDate, ub1.birthdayDate);
    });

    test('notificationId should be different for ambiguous concatenations', () {
      // These would collide if there were no delimiters:
      // "a1" + month 1 + day 11 -> "a1111"
      // "a11" + month 1 + day 1 -> "a1111"
      final ub1 = UserBirthday("a1", DateTime(2000, 1, 11), false, "");
      final ub2 = UserBirthday("a11", DateTime(2000, 1, 1), false, "");

      expect(ub1.notificationId, isNot(ub2.notificationId),
          reason: 'Ambiguous concatenations should be resolved by delimiters');

      // Another case:
      // "a" + month 11 + day 1 -> "a111"
      // "a1" + month 1 + day 1 -> "a111"
      final ub3 = UserBirthday("a", DateTime(2000, 11, 1), false, "");
      final ub4 = UserBirthday("a1", DateTime(2000, 1, 1), false, "");

      expect(ub3.notificationId, isNot(ub4.notificationId),
          reason: 'Ambiguous concatenations should be resolved by delimiters');
    });

    test('hashCode should avoid the same ambiguity', () {
      final ub1 = UserBirthday("a1", DateTime(2000, 1, 11), false, "");
      final ub2 = UserBirthday("a11", DateTime(2000, 1, 1), false, "");

      expect(ub1.hashCode, isNot(ub2.hashCode));
    });

    test('hashCode should be stable', () {
        final date = DateTime(1990, 5, 15);
        final ub1 = UserBirthday("John Doe", date, false, "");
        final ub2 = UserBirthday("John Doe", date, false, "");

        expect(ub1.hashCode, ub2.hashCode);
    });
  });
}
