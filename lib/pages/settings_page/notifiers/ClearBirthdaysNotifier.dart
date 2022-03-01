
import 'package:flutter/cupertino.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:birthday_calendar/service/service_locator.dart';

class ClearBirthdaysNotifier extends ValueNotifier<bool> {
  ClearBirthdaysNotifier() : super(false);

  StorageService _storageService = getIt<StorageService>();

  void clearBirthdays() async {
    value = await _storageService.clearAllBirthdays();
  }
}