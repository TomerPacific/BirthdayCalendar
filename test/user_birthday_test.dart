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
}
