
import 'permissions_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:birthday_calendar/constants.dart';

class PermissionsServiceImpl extends PermissionsService {
  @override
  Future<PermissionStatus> getPermissionStatus(String permissionName) async {
    PermissionStatus status = PermissionStatus.denied;
    switch(permissionName) {
      case contactsPermissionKey:
        status = await Permission.contacts.status;
        break;
      case notificationsPermissionKey:
        status = await Permission.notification.status;
        break;
    }

    return status;
  }

  @override
  Future<PermissionStatus> requestPermissionAndGetStatus(String permissionName) async {
    PermissionStatus status = PermissionStatus.denied;
    switch(permissionName) {
      case contactsPermissionKey:
        await Permission.contacts.shouldShowRequestRationale;
        status = await Permission.contacts.request();
        break;
      case notificationsPermissionKey:
        await Permission.notification.shouldShowRequestRationale;
        status = await Permission.notification.request();
        break;
    }

    return status;
  }

}