import 'package:birthday_calendar/service/StorageServiceSharedPreferences.dart';
import 'package:get_it/get_it.dart';
import 'package:birthday_calendar/service/StorageService.dart';

final getIt = GetIt.instance;

setupServiceLocator() {
  getIt.registerLazySingleton<StorageService>(() => StorageServiceSharedPreferences());
}