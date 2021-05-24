
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/models/setting.dart';

import 'detail_state.dart';

typedef SettingState = DetailState<Setting>;

class SettingCubit extends Cubit<SettingState> {
  final ApiRepository api;

  SettingCubit(this.api) : super(SettingState.loading());

  Future<void> load(int pk) async {
    emit(state.copyWith(isLoading: true));
    try {
      final settings = await api.getDevices();
      emit(SettingState.result(result: settings.results.first));
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