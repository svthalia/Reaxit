import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class ThemeChangeEvent extends ThemeEvent {
  final ThemeMode newMode;

  ThemeChangeEvent(this.newMode);

  @override
  List<Object> get props => [newMode];
}

class ThemeLoadEvent extends ThemeEvent {}

class ThemeBloc extends Bloc<ThemeEvent, ThemeMode> {
  ThemeBloc() : super(ThemeMode.system);

  @override
  Stream<ThemeMode> mapEventToState(ThemeEvent event) async* {
    if (event is ThemeLoadEvent) {
      yield* _mapThemeLoadEventToState();
    } else if (event is ThemeChangeEvent) {
      yield* _mapThemeChangeEventToState(event);
    }
  }

  Stream<ThemeMode> _mapThemeLoadEventToState() async* {
    var prefs = await SharedPreferences.getInstance();
    var modeString = prefs.getString('themeMode');
    if (modeString == null) {
      yield ThemeMode.system;
    } else if (modeString == 'system') {
      yield ThemeMode.system;
    } else if (modeString == 'light') {
      yield ThemeMode.light;
    } else if (modeString == 'dark') {
      yield ThemeMode.dark;
    }
  }

  Stream<ThemeMode> _mapThemeChangeEventToState(ThemeChangeEvent event) async* {
    var prefs = await SharedPreferences.getInstance();
    switch (event.newMode) {
      case ThemeMode.system:
        await prefs.setString('themeMode', 'system');
        break;
      case ThemeMode.light:
        await prefs.setString('themeMode', 'light');
        break;
      case ThemeMode.dark:
        await prefs.setString('themeMode', 'dark');
        break;
    }
    yield event.newMode;
  }
}

// TODO: make ThemeBloc a cubit?
