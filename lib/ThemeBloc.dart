import 'package:flutter_bloc/flutter_bloc.dart';

import 'ThemeState.dart';

enum ThemeEvent { toggleDark, toggleLight }

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {

  bool isDarkMode = false;

  ThemeBloc() : super(ThemeState.lightTheme) {
    on<ThemeEvent>((event, emit) {
      switch (event) {
        case ThemeEvent.toggleDark:
          this.isDarkMode = true;
          emit(ThemeState.darkTheme);
          break;
        case ThemeEvent.toggleLight:
          this.isDarkMode = false;
          emit(ThemeState.lightTheme);
          break;
      }
    });
  }

  bool isDarkModeOn() {
    return this.isDarkMode;
  }
}