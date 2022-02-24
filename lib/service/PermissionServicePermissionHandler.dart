
import 'package:birthday_calendar/service/PermissionsService.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionServicePermissionHandler extends PermissionsService {
  @override
  Future<PermissionStatus> getPermissionStatus(String permissionName) async {
    PermissionStatus status = PermissionStatus.denied;
    switch(permissionName) {
      case "contacts":
        status = await Permission.contacts.status;
        break;
    }

    return status;
  }

  @override
  Future<PermissionStatus> requestPermissionAndGetStatus(String permissionName) async {
    PermissionStatus status = false;
    switch(permissionName) {
      case "contacts":
        await Permission.contacts.shouldShowRequestRationale;
        status = await Permission.contacts.request();
        break;
    }

    return status;
  }

}