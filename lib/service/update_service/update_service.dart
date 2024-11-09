import 'package:flutter/material.dart';

abstract class UpdateService {
  void checkForInAppUpdate(Function onSuccess, Function onFailure, BuildContext context);
  bool isUpdateAvailable();
  bool isImmediateUpdatePossible();
  bool isFlexibleUpdatePossible();
  Future<void> applyImmediateUpdate(Function onSuccess, Function onFailure, BuildContext context);
  Future<void> startFlexibleUpdate();
}