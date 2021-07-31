import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:reaxit/api_repository.dart';
import 'package:reaxit/models/push_notification_category.dart';
import 'package:reaxit/models/device.dart';
import 'package:reaxit/push_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

class SettingsState extends Equatable {
  /// This can only be null when [isLoading] or [hasException] is true.
  final Device? device;

  /// This can only be null when [isLoading] or [hasException] is true.
  final List<PushNotificationCategory>? categories;

  /// A message describing why there are no settings or categories.
  final String? message;

  /// A list of settings is being loaded. If there is
  /// already a list of settings it is outdated.
  final bool isLoading;

  bool get hasException => message != null;

  @protected
  const SettingsState({
    required this.device,
    required this.categories,
    required this.isLoading,
    required this.message,
  }) : assert(
          (device != null && categories != null) ||
              isLoading ||
              message != null,
          'device and categories can only be null '
          'when isLoading or hasException is true.',
        );

  @override
  List<Object?> get props => [device, categories, message, isLoading];

  SettingsState copyWith({
    Device? device,
    List<PushNotificationCategory>? categories,
    bool? isLoading,
    String? message,
  }) =>
      SettingsState(
        device: device ?? this.device,
        categories: categories ?? this.categories,
        isLoading: isLoading ?? this.isLoading,
        message: message ?? this.message,
      );

  const SettingsState.result(
      {required Device this.device,
      required List<PushNotificationCategory> this.categories})
      : message = null,
        isLoading = false;

  const SettingsState.loading({this.device, this.categories})
      : message = null,
        isLoading = true;

  const SettingsState.failure({required String this.message})
      : device = null,
        categories = null,
        isLoading = false;
}

class SettingsCubit extends Cubit<SettingsState> {
  final ApiRepository api;
  final Future<FirebaseApp> firebaseInitialization;

  SettingsCubit(this.api, this.firebaseInitialization)
      : super(const SettingsState.loading());

  Future<void> setSetting(String key, bool value) async {
    if (state.device != null && state.categories != null) {
      Device device;
      if (value) {
        device = state.device!.copyWithReceiveCategory(
          state.device!.receiveCategory.toList()..add(key),
        );
      } else {
        device = state.device!.copyWithReceiveCategory(
          state.device!.receiveCategory.toList()..remove(key),
        );
      }

      var prefs = await SharedPreferences.getInstance();
      var deviceRegistrationId = prefs.getInt(
        deviceRegistrationIdPreferenceName,
      );
      if (deviceRegistrationId == null) {
        emit(const SettingsState.failure(
          message: 'Failed to register device for push notifications.',
        ));
      } else {
        await api.putDevice(id: deviceRegistrationId, device: device);
        emit(SettingsState.result(
          device: device,
          categories: state.categories!,
        ));
      }
    }
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    // TODO: Await initialization! Probably pass the initialization future through the constructor of this cubit.
    var token = await FirebaseMessaging.instance.getToken();
    var prefs = await SharedPreferences.getInstance();
    var deviceRegistrationId = prefs.getInt(deviceRegistrationIdPreferenceName);
    if (token == null) {
      emit(const SettingsState.failure(message: 'No device token found.'));
    } else if (deviceRegistrationId == null) {
      emit(const SettingsState.failure(
        message: 'Failed to register device for push notifications.',
      ));
    } else {
      try {
        final device = await api.getDevice(id: deviceRegistrationId);
        final categories = await api.getCategories();
        emit(SettingsState.result(
          device: device,
          categories: categories.results,
        ));
      } on ApiException catch (exception) {
        emit(SettingsState.failure(message: _failureMessage(exception)));
      }
    }
  }

  String _failureMessage(ApiException exception) {
    switch (exception) {
      case ApiException.noInternet:
        return 'Not connected to the internet.';
      default:
        return 'An unknown error occurred.';
    }
  }
}
