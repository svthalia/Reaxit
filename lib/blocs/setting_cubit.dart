import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState extends Equatable {
  /// This can only be null when [isLoading] or [hasException] is true.
  final Device? device;

  /// This can only be null when [isLoading] or [hasException] is true.
  final List<PushNotificationCategory>? categories;

  /// This can only be null when [isLoading] or [hasException] is true.
  final bool? hasPermissions;

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
    required this.hasPermissions,
  }) : assert(
         (device != null && categories != null && hasPermissions != null) ||
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
    bool? hasPermissions,
  }) => SettingsState(
    device: device ?? this.device,
    categories: categories ?? this.categories,
    isLoading: isLoading ?? this.isLoading,
    message: message ?? this.message,
    hasPermissions: hasPermissions ?? this.hasPermissions,
  );

  const SettingsState.result({
    required Device this.device,
    required List<PushNotificationCategory> this.categories,
    required this.hasPermissions,
  }) : message = null,
       isLoading = false;

  const SettingsState.loading({
    this.device,
    this.categories,
    this.hasPermissions,
  }) : message = null,
       isLoading = true;

  const SettingsState.failure({required String this.message})
    : device = null,
      categories = null,
      hasPermissions = null,
      isLoading = false;
}

class SettingsCubit extends Cubit<SettingsState> {
  final ApiRepository api;

  static const _devicePkPreferenceKey = 'deviceRegistrationId';

  SettingsCubit(this.api) : super(const SettingsState.loading());

  Future<void> setSetting(String key, bool value) async {
    final device = state.device;
    if (state.device != null && state.categories != null) {
      List<String> newReceiveCategory = state.device!.receiveCategory;
      if (value) {
        newReceiveCategory.add(key);
      } else {
        newReceiveCategory.remove(key);
      }

      final newDevice = await api.updateDeviceReceiveCategory(
        pk: device!.pk,
        receiveCategory: newReceiveCategory,
      );

      emit(state.copyWith(device: newDevice));
    }
  }

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));

    try {
      final prefs = await SharedPreferences.getInstance();
      final devicePk = prefs.getInt(_devicePkPreferenceKey);

      // Get notification permission status.
      final fm = FirebaseMessaging.instance;
      final settings = await fm.getNotificationSettings();
      final hasPermissions =
          settings.authorizationStatus == AuthorizationStatus.authorized;

      if (devicePk == null) {
        emit(
          const SettingsState.failure(
            message: 'Failed to register device for push notifications.',
          ),
        );
      } else {
        final device = await api.getDevice(pk: devicePk);
        final categories = await api.getCategories();
        emit(
          SettingsState.result(
            device: device,
            categories: categories.results,
            hasPermissions: hasPermissions,
          ),
        );
      }
    } on ApiException catch (exception) {
      emit(SettingsState.failure(message: exception.message));
    } catch (_) {
      emit(
        const SettingsState.failure(message: 'An unknown exception occurred'),
      );
    }
  }
}
