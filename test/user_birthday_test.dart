import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserBirthday.fromJson', () {
    test('handles missing hasNotification and phoneNumber keys', () {
      final json = {
        'name': 'Alice',
        'birthdayDate': '1990-06-15T00:00:00.000',
      };

      final userBirthday = UserBirthday.fromJson(json);

      expect(userBirthday.name, equals('Alice'));
      expect(userBirthday.hasNotification, isFalse);
      expect(userBirthday.phoneNumber, equals(''));
    });

    test('handles null hasNotification and phoneNumber keys', () {
      final json = {
        'name': 'Alice',
        'birthdayDate': '1990-06-15T00:00:00.000',
        'hasNotification': null,
        'phoneNumber': null,
      };

      final userBirthday = UserBirthday.fromJson(json);

      expect(userBirthday.hasNotification, isFalse);
      expect(userBirthday.phoneNumber, equals(''));
    });

    test('handles missing name and date keys', () {
      final json = <String, dynamic>{};

      final before = DateTime.now();
      final userBirthday = UserBirthday.fromJson(json);
      final after = DateTime.now();

      expect(userBirthday.name, equals(''));
      expect(userBirthday.hasNotification, isFalse);
      expect(userBirthday.phoneNumber, equals(''));
      expect(!userBirthday.birthdayDate.isBefore(before), isTrue);
      expect(!userBirthday.birthdayDate.isAfter(after), isTrue);
    });
  });

  group('UserBirthday equality and hashCode', () {
    test('same name, month, day but different year should be equal', () {
      final birthday1 = UserBirthday('Alice', DateTime(1990, 6, 15), false, '');
      final birthday2 = UserBirthday('Alice', DateTime(2000, 6, 15), true, '123');

      expect(birthday1 == birthday2, isTrue);
      expect(birthday1.hashCode, equals(birthday2.hashCode));
    });

    test('different name should not be equal', () {
      final birthday1 = UserBirthday('Alice', DateTime(1990, 6, 15), false, '');
      final birthday2 = UserBirthday('Bob', DateTime(1990, 6, 15), false, '');

      expect(birthday1 == birthday2, isFalse);
    });

    test('different month should not be equal', () {
      final birthday1 = UserBirthday('Alice', DateTime(1990, 6, 15), false, '');
      final birthday2 = UserBirthday('Alice', DateTime(1990, 7, 15), false, '');

      expect(birthday1 == birthday2, isFalse);
      expect(birthday1.hashCode, isNot(equals(birthday2.hashCode)));
    });

    test('different day should not be equal', () {
      final birthday1 = UserBirthday('Alice', DateTime(1990, 6, 15), false, '');
      final birthday2 = UserBirthday('Alice', DateTime(1990, 6, 16), false, '');

      expect(birthday1 == birthday2, isFalse);
      expect(birthday1.hashCode, isNot(equals(birthday2.hashCode)));
    });

    test('identical objects should be equal', () {
      final birthday = UserBirthday('Alice', DateTime(1990, 6, 15), false, '');
      expect(birthday == birthday, isTrue);
    });

    test('comparison with different type should be false', () {
      final birthday = UserBirthday('Alice', DateTime(1990, 6, 15), false, '');
      expect(birthday == 'Alice', isFalse);
    });
  });
}
