import 'package:birthday_calendar/service/storage_service/storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ClearNotificationsEvent { ClearedNotifications }

class ClearNotificationsBloc extends Bloc<ClearNotificationsEvent, bool> {
  ClearNotificationsBloc(StorageService storageService) : super(false) {
    on<ClearNotificationsEvent>((event, emit) async {
      if (event == ClearNotificationsEvent.ClearedNotifications) {
        storageService.clearAllBirthdays();
        emit(true);
      }
    });
  }
}
