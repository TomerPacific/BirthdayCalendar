import 'dart:async';
import 'package:birthday_calendar/model/userBirthday.dart';
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
    String json = _sharedPreferences.getString(date);
    if (json == null) {
      return [];
    }
    List decoded = jsonDecode(json);
    List<UserBirthday> birthdays = decoded.map((e) => UserBirthday.fromJson(e)).toList();
    return birthdays;
  }

  void setBirthdaysForDate(String date, List<UserBirthday> birthdays) {
    String encoded = jsonEncode(birthdays);
    _sharedPreferences.setString(date, encoded);
  }

}
