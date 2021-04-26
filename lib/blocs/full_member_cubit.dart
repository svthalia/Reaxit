import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models/member.dart';

class FullMemberCubit extends Cubit<DetailState<FullMember>> {
  final ApiRepository api;

  FullMemberCubit(this.api) : super(DetailState<FullMember>.loading());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final member = await api.getMe();
      emit(DetailState.result(result: member));
    } on ApiException catch (exception) {
      emit(DetailState.failure(message: _failureMessage(exception)));
    }
  }

  Future<void> updateAvatar(File file) async {
    await api.updateAvatar(file);
    await load();
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
