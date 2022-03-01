import 'package:permission_handler/permission_handler.dart';

abstract class PermissionsService {
  Future<PermissionStatus> getPermissionStatus(String permissionName);
  Future<PermissionStatus> requestPermissionAndGetStatus(String permissionName);
}