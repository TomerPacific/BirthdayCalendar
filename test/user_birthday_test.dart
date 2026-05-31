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

    test('hashCode should be stable', () {
        final date = DateTime(1990, 5, 15);
        final ub1 = UserBirthday("John Doe", date, false, "");
        final ub2 = UserBirthday("John Doe", date, false, "");

        expect(ub1.hashCode, ub2.hashCode);
    });
  });
}
