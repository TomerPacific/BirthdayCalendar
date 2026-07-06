import 'package:birthday_calendar/model/user_birthday.dart';

sealed class BirthdaysState {}

class BirthdaysLoaded extends BirthdaysState {
  final DateTime date;
  final List<UserBirthday> birthdays;

  BirthdaysLoaded({required this.date, required this.birthdays});
}

class BirthdaysShowDialog extends BirthdaysState {}
