import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ThemeEvent { toggleDark, toggleLight }

class ThemeBloc extends Bloc<ThemeEvent, ThemeMode> {
  ThemeBloc() : super(ThemeMode.light) {
    on<ThemeEvent>((event, emit) {
      emit(event == ThemeEvent.toggleDark ? ThemeMode.dark : ThemeMode.light);
    });
  }
}
