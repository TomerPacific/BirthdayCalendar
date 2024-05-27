
import 'storage_service/storage_service.dart';
import 'storage_service/shared_preferences_storage.dart';
import 'date_service/date_service.dart';
import 'date_service/date_service_impl.dart';
import 'notification_service/notification_service_impl.dart';
import 'notification_service/notification_service.dart';
import 'package:birthday_calendar/page/settings_page/settings_screen_manager.dart';
import 'package:birthday_calendar/service/permission_service/permissions_service.dart';
import 'package:birthday_calendar/service/permission_service/permissions_service_impl.dart';
import 'package:birthday_calendar/service/snackbar_service/SnackbarService.dart';
import 'package:birthday_calendar/service/snackbar_service/SnackbarServiceImpl.dart';
import 'version_specific_service/VersionSpecificService.dart';
import 'version_specific_service/VersionSpecificServiceImpl.dart';
import 'package:birthday_calendar/service/update_service/update_service.dart';
import 'package:birthday_calendar/service/update_service/update_service_impl.dart';

import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

setupServiceLocator() {
  getIt.registerLazySingleton<DateService>(() => DateServiceImpl());
  getIt.registerLazySingleton<StorageService>(() => StorageServiceSharedPreferences());
  getIt.registerLazySingleton<NotificationService>(() => NotificationServiceImpl());
  getIt.registerLazySingleton<PermissionsService>(() => PermissionsServiceImpl());
  getIt.registerLazySingleton<SettingsScreenManager>(() => SettingsScreenManager());
  getIt.registerLazySingleton<SnackbarService>(() => SnackbarServiceImpl());
  getIt.registerLazySingleton<VersionSpecificService>(() => VersionSpecificServiceImpl());
  getIt.registerLazySingleton<UpdateService>(() => UpdateServiceImpl());
}