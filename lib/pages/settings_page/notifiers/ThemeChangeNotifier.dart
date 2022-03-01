
import 'package:flutter/cupertino.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:birthday_calendar/service/service_locator.dart';

class ThemeChangeNotifier extends ValueNotifier<bool> {

  StorageService _storageService = getIt<StorageService>();

  ThemeChangeNotifier() : super(false) {
    _getThemeModeFromStorage();
  }

  void _getThemeModeFromStorage() async {
    value = await _storageService.getThemeModeSetting();
  }



  void toggleTheme() {
    value = !value;
    _storageService.saveThemeModeSetting(value);
  }

}