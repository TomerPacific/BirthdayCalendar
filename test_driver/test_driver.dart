

// import 'dart:io';
// import 'package:path/path.dart';
// import 'package:integration_test/integration_test_driver_extended.dart';
// import 'package:flutter_driver/flutter_driver.dart';
//
// Future<void> main() async {
//   final Map<String, String> envVars = Platform.environment;
//
//   String? adbPath = join(envVars['ANDROID_SDK_ROOT'] ?? "",
//     'platform-tools',
//     Platform.isWindows ? 'adb.exe' : 'adb',
//   );
//     await Process.run(
//         adbPath,
//         ['shell' ,'pm', 'grant', 'com.tomerpacific.birthday_calendar', 'android.permission.READ_CONTACTS'],
//         runInShell: true);
//     final FlutterDriver driver = await FlutterDriver.connect();
//     await integrationDriver(driver: driver);
// }

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();