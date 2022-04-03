
import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionNotifier extends ValueNotifier<String> {

  VersionNotifier() : super("") {
    _getVersionFromPackage();
  }

  void _getVersionFromPackage() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    value = packageInfo.version;
  }
}