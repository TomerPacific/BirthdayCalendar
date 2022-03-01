
import 'package:flutter/cupertino.dart';
import '../service/storage_service/storage_service.dart';
import 'package:birthday_calendar/service/service_locator.dart';

class ThemeChangeNotifier extends ValueNotifier<bool> {

  ThemeChangeNotifier(): super(false);

  StorageService _storageService = getIt<StorageService>();

  void toggleTheme() {
    value = !value;
    _storageService.saveThemeModeSetting(value);
  }

}