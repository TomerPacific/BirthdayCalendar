import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ThemeEvent { toggleDark, toggleLight }

class ThemeBloc extends Bloc<ThemeEvent, ThemeMode> {
  ThemeBloc(StorageService storageService, bool isDarkMode) : super(isDarkMode ? ThemeMode.dark : ThemeMode.light) {
    on<ThemeEvent>((event, emit) {
      ThemeMode themeMode = event == ThemeEvent.toggleDark ? ThemeMode.dark : ThemeMode.light;
      emit(themeMode);
      storageService.saveThemeModeSetting(themeMode == ThemeMode.dark ? true : false);
    });
  }
}
