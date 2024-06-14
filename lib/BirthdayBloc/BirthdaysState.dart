import 'package:birthday_calendar/model/user_birthday.dart';

class BirthdaysState {
  final DateTime? date;
  final List<UserBirthday>? birthdays;
  final bool showAddBirthdayDialog;

  BirthdaysState(
      {this.date, this.birthdays, required this.showAddBirthdayDialog});
}
