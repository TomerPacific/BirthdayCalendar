import 'package:flutter/material.dart';
import 'package:birthday_calendar/service/snackbar_service/SnackbarService.dart';

class SnakcbarServiceImpl extends SnackbarService {
  @override
  void showSnackbarWithMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message),
        ));
  }

}