import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

enum ContactsPermissionStatusEvent { PermissionDenied, PermissionGranted, PermissionPermanentlyDenied }

class ContactsPermissionStatusBloc extends Bloc<ContactsPermissionStatusEvent, PermissionStatus> {

  ContactsPermissionStatusBloc() : super(PermissionStatus.denied) {
    on<ContactsPermissionStatusEvent>((event, emit) {
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