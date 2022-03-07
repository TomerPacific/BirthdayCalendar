
import 'package:flutter/cupertino.dart';

abstract class SnackbarService {
  void showSnackbarWithMessage(BuildContext context, String message);
}