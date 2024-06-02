

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum VersionEvent { versionUnknown }

class VersionBloc extends Bloc<VersionEvent, String> {

  VersionBloc() : super("") {
    on<VersionEvent>((event, emit) async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      emit(packageInfo.version);
    });
  }
}