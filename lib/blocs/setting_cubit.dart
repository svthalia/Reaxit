
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/push_notifications.dart';
import 'package:reaxit/models/setting.dart';

import 'detail_state.dart';

typedef SettingState = DetailState<Setting>;

class SettingsCubit extends Cubit<SettingState> {
  final ApiRepository api;

  SettingsCubit(this.api) : super(SettingState.loading());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    print(PushNotificationsManager().init());
    try {
      print('here2');
      await PushNotificationsManager().init();
      final deviceId = await PushNotificationsManager().getToken();
      print('Device id: $deviceId');
      if (deviceId != null) {
        final setting = await api.getDevice(id: deviceId);
        emit(SettingState.result(result: setting));
      }
      else {
        emit(SettingState.failure(message: 'No device token found.'));
      }
    } on ApiException catch (exception) {
      emit(SettingState.failure(message: _failureMessage(exception)));
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