import 'package:flutter/material.dart';

class ThemeState {
  final ThemeData themeData;

  ThemeState(this.themeData);

  static ThemeState get darkTheme =>
      ThemeState(ThemeData.dark().copyWith(

      ));

  static ThemeState get lightTheme =>
      ThemeState(ThemeData.light().copyWith(

      ));
}