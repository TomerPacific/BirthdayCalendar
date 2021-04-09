
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _dateService = NotificationService
      ._internal();

  factory NotificationService() {
    return _dateService;
  }

  NotificationService._internal();

}