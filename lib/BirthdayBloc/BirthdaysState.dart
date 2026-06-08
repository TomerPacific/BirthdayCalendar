import 'package:birthday_calendar/model/user_birthday.dart';

class BirthdaysState {
  final DateTime? date;
  final List<UserBirthday>? birthdays;
  final bool showAddBirthdayDialog;

  BirthdaysState(
      {this.date, List<UserBirthday>? birthdays, required this.showAddBirthdayDialog})
      : this.birthdays = birthdays != null ? List.unmodifiable(birthdays) : null;
}
