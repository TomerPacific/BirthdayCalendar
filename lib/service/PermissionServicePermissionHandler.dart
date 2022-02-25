
import 'package:birthday_calendar/service/PermissionsService.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:birthday_calendar/constants.dart';

class PermissionServicePermissionHandler extends PermissionsService {
  @override
  Future<PermissionStatus> getPermissionStatus(String permissionName) async {
    PermissionStatus status = PermissionStatus.denied;
    switch(permissionName) {
      case contactsPermissionKey:
        status = await Permission.contacts.status;
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
    }

    return status;
  }

}