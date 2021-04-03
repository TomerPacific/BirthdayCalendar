import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';


class SharedPrefs {
  static SharedPreferences _sharedPreferences;

  init() async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }
  }

}

final sharedPrefs = SharedPrefs();