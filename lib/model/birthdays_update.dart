import 'package:birthday_calendar/model/user_birthday.dart';

class BirthdaysUpdate {
  final DateTime date;
  final List<UserBirthday> birthdays;

  BirthdaysUpdate(this.date, List<UserBirthday> birthdays)
      : this.birthdays = List.unmodifiable(birthdays);
}
