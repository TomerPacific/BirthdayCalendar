import 'package:birthday_calendar/service/notification_service/notification_service.dart';
import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ClearNotificationsEvent {}

class ClearNotificationsRequested extends ClearNotificationsEvent {}

sealed class ClearNotificationsState {}

class ClearNotificationsInitial extends ClearNotificationsState {}

class ClearNotificationsCompleted extends ClearNotificationsState {}

class ClearNotificationsBloc
    extends Bloc<ClearNotificationsEvent, ClearNotificationsState> {
  final StorageService storageService;
  final NotificationService notificationService;

  ClearNotificationsBloc(this.storageService, this.notificationService)
      : super(ClearNotificationsInitial()) {
    on<ClearNotificationsRequested>((event, emit) async {
      await storageService.clearAllBirthdays();
      await notificationService.cancelAllNotifications();
      emit(ClearNotificationsCompleted());
    });
  }
}
