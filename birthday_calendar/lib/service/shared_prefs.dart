import 'dart:async';
import 'package:birthday_calendar/model/user_birthday.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPrefs {
  static SharedPreferences _sharedPreferences;

  factory SharedPrefs() => SharedPrefs._internal();

  SharedPrefs._internal();

  Future<void> init() async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }
  }

  List<UserBirthday> getBirthdaysForDate(String date) {
    String birthdaysForDate = _sharedPreferences.getString(date);
    if (birthdaysForDate == null) {
      return [];
    }
    List decodedBirthdaysForDate = jsonDecode(birthdaysForDate);
    List<UserBirthday> birthdays = decodedBirthdaysForDate.map((decodedBirthday) => UserBirthday.fromJson(decodedBirthday)).toList();
    return birthdays;
  }

  void setBirthdaysForDate(String date, List<UserBirthday> birthdays) {
    String encoded = jsonEncode(birthdays);
    _sharedPreferences.setString(date, encoded);
  }

  void updateNotificationStatusForBirthday(UserBirthday birthday, bool updatedStatus) {
    List<UserBirthday> birthdays = getBirthdaysForDate(birthday.birthdayDate);
    for(int i = 0; i < birthdays.length; i++) {
      UserBirthday savedBirthday = birthdays[i];
      if (savedBirthday.equals(birthday)) {
        savedBirthday.updateNotificationStatus(updatedStatus);
      }
    }

    setBirthdaysForDate(birthday.birthdayDate, birthdays);

  }

}
