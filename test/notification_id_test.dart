import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserBirthday notificationId', () {
    test('is stable across multiple instantiations with the same name and date', () {
      final date = DateTime(1990, 6, 15);
      final a = UserBirthday('Alice', date, false, '');
      final b = UserBirthday('Alice', date, false, '');
      expect(a.notificationId, equals(b.notificationId));
    });

    test('differs for different names on the same date', () {
      final date = DateTime(1990, 6, 15);
      final alice = UserBirthday('Alice', date, false, '');
      final bob   = UserBirthday('Bob',   date, false, '');
      expect(alice.notificationId, isNot(equals(bob.notificationId)));
    });

    test('differs for the same name on different month/day', () {
      final a = UserBirthday('Alice', DateTime(1990, 6, 15), false, '');
      final b = UserBirthday('Alice', DateTime(1990, 7, 15), false, '');
      expect(a.notificationId, isNot(equals(b.notificationId)));
    });

    test('ignores the year — only name, month, day matter', () {
      final a = UserBirthday('Alice', DateTime(1990, 6, 15), false, '');
      final b = UserBirthday('Alice', DateTime(2024, 6, 15), false, '');
      expect(a.notificationId, equals(b.notificationId));
    });

    test('fromJson uses stored notificationId when present', () {
      final original = UserBirthday('Alice', DateTime(1990, 6, 15), false, '');
      final decoded  = UserBirthday.fromJson(original.toJson());
      expect(decoded.notificationId, equals(original.notificationId));
    });

    test('fromJson computes deterministic fallback when notificationId is absent', () {
      final original = UserBirthday('Alice', DateTime(1990, 6, 15), false, '');
      final json = original.toJson()..remove('notificationId');

      final a = UserBirthday.fromJson(json);
      final b = UserBirthday.fromJson(json);
      expect(a.notificationId, equals(b.notificationId));
      expect(a.notificationId, equals(original.notificationId));
    });

    test('explicit notificationId overrides computed value', () {
      final b = UserBirthday('Alice', DateTime(1990, 6, 15), false, '',
          notificationId: 42);
      expect(b.notificationId, equals(42));
    });
  });

  group('UserBirthday equality and contactId', () {
    test('equality uses contactId when both have it', () {
      final date = DateTime(1990, 6, 15);
      final a = UserBirthday('Alice', date, false, '', contactId: '1');
      final b = UserBirthday('Alice renamed', date, false, '', contactId: '1');
      expect(a, equals(b));
    });

    test('equality distinguishes same names with different contactIds', () {
      final date = DateTime(1990, 6, 15);
      final a = UserBirthday('Alice', date, false, '', contactId: '1');
      final b = UserBirthday('Alice', date, false, '', contactId: '2');
      expect(a, isNot(equals(b)));
    });

    test('equality falls back to name and date when contactId is missing', () {
      final date = DateTime(1990, 6, 15);
      final a = UserBirthday('Alice', date, false, '', contactId: '');
      final b = UserBirthday('Alice', date, false, '', contactId: '1');
      expect(a, equals(b));
    });

    test('fromJson preserves contactId', () {
      final original = UserBirthday('Alice', DateTime(1990, 6, 15), false, '', contactId: 'abc');
      final decoded = UserBirthday.fromJson(original.toJson());
      expect(decoded.contactId, equals('abc'));
    });
  });
}
