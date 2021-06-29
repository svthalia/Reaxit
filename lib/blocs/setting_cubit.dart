
import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/models/setting.dart';

import 'detail_state.dart';

typedef SettingState = DetailState<Setting>;

class SettingsCubit extends Cubit<SettingState> {
  final ApiRepository api;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  int? deviceRegistrationId;

  SettingsCubit(this.api) : super(SettingState.loading()) {
    print("Calling register");
    register();
    _firebaseMessaging.onTokenRefresh.listen((String token) {
      registerToken(token);
    });
  }

  Future<bool> register() async {
    var settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      return false;
    }

    var token = await _firebaseMessaging.getToken();
    if (token == null) {
      return false;
    }
    return await registerToken(token);
  }

  Future<bool> registerToken(String token) async {
    try {
      var setting = await api.registerDevice(token, Platform.isIOS ? 'ios' : 'android');
      deviceRegistrationId = setting.pk;
      return true;
    } on ApiException {
      return false;
    }
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    var token = await _firebaseMessaging.getToken();
    if (token == null) {
      emit(SettingState.failure(message: 'No device token found.'));
    }
    else if (deviceRegistrationId == null) {
      emit(SettingState.failure(message: 'Failed to register device for push notifications.'));
    }
    else {
      try {
        final setting = await api.getDevice(id: deviceRegistrationId!);
        emit(SettingState.result(result: setting));
      } on ApiException catch (exception) {
        emit(SettingState.failure(message: _failureMessage(exception)));
      }
    }
  }

  String _failureMessage(ApiException exception) {
    print(exception);
    switch (exception) {
      case ApiException.noInternet:
        return 'Not connected to the internet.';
      default:
        return 'An unknown error occurred.';
    }
  }
}