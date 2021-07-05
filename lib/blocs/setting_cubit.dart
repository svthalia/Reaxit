
import 'dart:io' show Platform;

import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/models/category.dart';
import 'package:reaxit/models/device.dart';
import 'package:reaxit/push_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'detail_state.dart';

class SettingState extends Equatable {
  /// This can only be null when [isLoading] or [hasException] is true.
  final Device? device;

  /// This can only be null when [isLoading] or [hasException] is true.
  final List<Category>? categories;

  /// A message describing why there are no settings or categories.
  final String? message;

  /// A list of settings is being loaded. If there is already a list of settings it is outdated.
  final bool isLoading;

  bool get hasException => message != null;

  @protected
  const SettingState({
    required this.device,
    required this.categories,
    required this.isLoading,
    required this.message,
  }) : assert(
  categories != null || isLoading || message != null,
  'foodEvent can only be null when isLoading or hasException is true.',
  );

  @override
  List<Object?> get props => [device, categories, message, isLoading];

  SettingState copyWith({
    Device? device,
    List<Category>? categories,
    bool? isLoading,
    String? message,
  }) =>
      SettingState(
        device: device ?? this.device,
        categories: categories ?? this.categories,
        isLoading: isLoading ?? this.isLoading,
        message: message ?? this.message,
      );

  SettingState.result(
      {required Device device, required List<Category> categories})
      : device = device,
        categories = categories,
        message = null,
        isLoading = false;

  SettingState.loading({this.device, this.categories})
      : message = null,
        isLoading = true;

  SettingState.failure({required String message})
      : device = null,
        categories = null,
        message = message,
        isLoading = false;
}

class SettingsCubit extends Cubit<SettingState> {
  final ApiRepository api;

  SettingsCubit(this.api) : super(SettingState.loading());

  Future<void> setSetting(String key, bool value) async {
    if (state.device != null) {
      var copy = state.device!.copy();
      if (value) {
        copy.receiveCategory.add(key);
      }
      else {
        copy.receiveCategory.remove(key);
      }
      emit(SettingState.result(device: copy, categories: state.categories!));
      var prefs = await SharedPreferences.getInstance();
      var deviceRegistrationId = prefs.getInt(deviceRegistrationIdPreferenceName);
      if (deviceRegistrationId == null) {
        emit(SettingState.failure(message: 'Failed to register device for push notifications.'));
      }
      else {
        await api.putDevice(id: deviceRegistrationId, device: copy);
      }
    }
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    var token = await FirebaseMessaging.instance.getToken();
    var prefs = await SharedPreferences.getInstance();
    var deviceRegistrationId = prefs.getInt(deviceRegistrationIdPreferenceName);
    if (token == null) {
      emit(SettingState.failure(message: 'No device token found.'));
    }
    else if (deviceRegistrationId == null) {
      emit(SettingState.failure(message: 'Failed to register device for push notifications.'));
    }
    else {
      try {
        final setting = await api.getDevice(id: deviceRegistrationId);
        final categories = await api.getCategories();
        emit(SettingState.result(device: setting, categories: categories.results));
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