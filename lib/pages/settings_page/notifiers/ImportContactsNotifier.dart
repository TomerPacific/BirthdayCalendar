
import 'package:flutter/cupertino.dart';

class ImportContactsNotifier extends ValueNotifier<bool> {
  ImportContactsNotifier() : super(false);

  void toggleImportContacts() {
    value = !value;
  }

}