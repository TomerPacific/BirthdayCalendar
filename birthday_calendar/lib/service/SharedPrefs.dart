import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';


class SharedPrefs {
  static SharedPreferences _sharedPreferences;

  factory SharedPrefs() => SharedPrefs._internal();

  SharedPrefs._internal();

  Future<void> init() async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }
  }

  List<String> getBirthdaysForDate(String date) {
    return _sharedPreferences.getStringList(date);
  }

  void setBirthdaysForDate(String date, List<String> birthdays) {
    _sharedPreferences.setStringList(date, birthdays);
  }

}
