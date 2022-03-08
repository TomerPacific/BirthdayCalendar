
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:birthday_calendar/service/service_locator.dart';

class ImportContactsNotifier extends ValueNotifier<bool> {
  ImportContactsNotifier() : super(false) {
    _getImportContactsStatus();
  }

  StorageService _storageService = getIt<StorageService>();

  void _getImportContactsStatus() async {
    bool isContactsPermissionPermanentlyDenied = await _storageService.getContactsPermissionStatus();
    value = isContactsPermissionPermanentlyDenied;
  }

  void toggleImportContacts() {
    value = !value;
  }

}