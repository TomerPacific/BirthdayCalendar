import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ClearNotificationsEvent { ClearedNotifications }

class ClearNotificationsBloc extends Bloc<ClearNotificationsEvent, bool> {
  ClearNotificationsBloc(
      StorageService storageService, NotificationService notificationService)
      : super(false) {
    on<ClearNotificationsEvent>((event, emit) async {
      if (event == ClearNotificationsEvent.ClearedNotifications) {
        await storageService.clearAllBirthdays();
        await notificationService.cancelAllNotifications();
        emit(true);
      }
    });
  }
}
