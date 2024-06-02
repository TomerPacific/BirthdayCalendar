import 'notification_service/notification_service_impl.dart';
import 'notification_service/notification_service.dart';
import 'package:birthday_calendar/service/permission_service/permissions_service.dart';
import 'package:birthday_calendar/service/permission_service/permissions_service_impl.dart';
import 'package:birthday_calendar/service/update_service/update_service.dart';
import 'package:birthday_calendar/service/update_service/update_service_impl.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

setupServiceLocator() {
  getIt.registerLazySingleton<NotificationService>(() => NotificationServiceImpl());
  getIt.registerLazySingleton<PermissionsService>(() => PermissionsServiceImpl());
  getIt.registerLazySingleton<UpdateService>(() => UpdateServiceImpl());
}