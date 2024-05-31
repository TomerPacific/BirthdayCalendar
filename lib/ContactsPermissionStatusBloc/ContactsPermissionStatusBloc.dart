import 'package:birthday_calendar/service/contacts_service/contacts_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

enum ContactsPermissionStatusEvent { PermissionUnknown, PermissionDenied, PermissionGranted, PermissionPermanentlyDenied }

class ContactsPermissionStatusBloc extends Bloc<ContactsPermissionStatusEvent, PermissionStatus> {

  ContactsPermissionStatusBloc(ContactsService contactsService) : super(PermissionStatus.denied) {

    on<ContactsPermissionStatusEvent>((event, emit) async {
      if (event == ContactsPermissionStatusEvent.PermissionUnknown) {
        bool permissionStatus = await contactsService.isContactsPermissionsPermanentlyDenied();
        if (permissionStatus) {
          emit(PermissionStatus.permanentlyDenied);
          return;
        }
      }
      emit(_convertEventNameToPermissionStatus(event));
    });
  }


  PermissionStatus _convertEventNameToPermissionStatus(ContactsPermissionStatusEvent event) {
    switch (event) {
      case ContactsPermissionStatusEvent.PermissionDenied:
        return PermissionStatus.denied;
      case ContactsPermissionStatusEvent.PermissionGranted:
        return PermissionStatus.granted;
      case ContactsPermissionStatusEvent.PermissionPermanentlyDenied:
        return PermissionStatus.permanentlyDenied;
      default:
        return PermissionStatus.denied;
    }
  }
}