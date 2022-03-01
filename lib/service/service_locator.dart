import 'package:birthday_calendar/service/StorageService.dart';
import 'package:birthday_calendar/service/StorageServiceSharedPreferences.dart';
import 'package:birthday_calendar/service/date_service.dart';
import 'package:birthday_calendar/service/date_service_impl.dart';
import 'package:birthday_calendar/service/notification_service_impl.dart';
import 'package:birthday_calendar/service/notification_service.dart';
import 'package:birthday_calendar/widget/settings_screen_manager.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

setupServiceLocator() {
  getIt.registerLazySingleton<DateService>(() => DateServiceImpl());
  getIt.registerLazySingleton<StorageService>(() => StorageServiceSharedPreferences());
  getIt.registerLazySingleton<NotificationService>(() => NotificationServiceImpl());
  getIt.registerLazySingleton<SettingsScreenManager>(() => SettingsScreenManager());
}