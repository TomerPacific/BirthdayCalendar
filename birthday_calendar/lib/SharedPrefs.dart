import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';


class SharedPrefs {
  static SharedPreferences _sharedPreferences;

  factory SharedPrefs() => SharedPrefs._internal();

  SharedPrefs._internal();

  Future<void>init() async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }
  }

}
