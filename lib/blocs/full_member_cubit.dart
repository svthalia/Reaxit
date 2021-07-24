import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api_repository.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models/member.dart';

typedef FullMemberState = DetailState<FullMember>;

class FullMemberCubit extends Cubit<FullMemberState> {
  final ApiRepository api;

  FullMemberCubit(this.api) : super(const FullMemberState.loading());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final member = await api.getMe();
      emit(FullMemberState.result(result: member));
    } on ApiException catch (exception) {
      emit(FullMemberState.failure(message: _failureMessage(exception)));
    }
  }

  Future<void> updateAvatar(File file) async {
    await api.updateAvatar(file);
    await load();
  }

  Future<void> updateDescription(String description) async {
    await api.updateDescription(description);
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
