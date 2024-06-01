
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:birthday_calendar/service/service_locator.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreenManager extends ChangeNotifier {

  StorageService _storageService = getIt<StorageService>();

  ThemeMode _themeMode = ThemeMode.light;
  String _version = "";
  bool _didClearNotifications = false;
  bool _isContactsPermissionPermanentlyDenied = false;

  get themeMode => _themeMode;
  get version => _version;
  get didClearNotifications => _didClearNotifications;
  get isContactsPermissionPermanentlyDenied => _isContactsPermissionPermanentlyDenied;

  SettingsScreenManager() {
    _gatherDataFromStorage();
    _getVersionInfo();
  }

  void _gatherDataFromStorage() async {
    bool isDarkModeEnabled = await _storageService.getThemeModeSetting();
    _themeMode = isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light;
    _isContactsPermissionPermanentlyDenied = await _storageService.getIsContactPermissionPermanentlyDenied();
    notifyListeners();
  }

  void _getVersionInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _version = packageInfo.version;
    notifyListeners();
  }

  void onClearBirthdaysPressed() async {
    _storageService.clearAllBirthdays();
    _didClearNotifications = true;
  }

  void setOnClearBirthdaysFlag(bool state) {
    _didClearNotifications = state;
  }
}