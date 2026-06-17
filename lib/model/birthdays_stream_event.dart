import 'package:birthday_calendar/model/user_birthday.dart';

class BirthdaysStreamEvent {
  final DateTime date;
  final List<UserBirthday> birthdays;

  BirthdaysStreamEvent(this.date, this.birthdays);
}
