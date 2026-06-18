import 'package:flutter/material.dart';
import 'permissions_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:birthday_calendar/constants.dart';
import 'package:birthday_calendar/l10n/app_localizations.dart';

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
  Future<PermissionStatus> requestPermissionAndGetStatus(String permissionName, {BuildContext? context}) async {
    PermissionStatus status = PermissionStatus.denied;
    switch(permissionName) {
      case contactsPermissionKey: {
        bool showRationale = await Permission.contacts.shouldShowRequestRationale;
        if (showRationale && context != null && context.mounted) {
          await _showRationaleDialog(context, AppLocalizations.of(context)!.appTitle, AppLocalizations.of(context)!.contactsPermissionRationale);
        }
        status = await Permission.contacts.request();
        break;
      }
      case notificationsPermissionKey: {
        bool showRationale = await Permission.notification.shouldShowRequestRationale;
        if (showRationale && context != null && context.mounted) {
          await _showRationaleDialog(context, AppLocalizations.of(context)!.appTitle, AppLocalizations.of(context)!.notificationPermissionRationale);
        }
        status = await Permission.notification.request();
        break;
      }
    }

    return status;
  }

  Future<void> _showRationaleDialog(BuildContext context, String title, String content) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

}