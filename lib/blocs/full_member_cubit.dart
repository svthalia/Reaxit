import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models/member.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

typedef FullMemberState = DetailState<FullMember>;

class FullMemberCubit extends Cubit<FullMemberState> {
  final ApiRepository api;

  FullMemberCubit(this.api) : super(const FullMemberState.loading());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final member = await api.getMe();
      // Set username for sentry.
      Sentry.configureScope(
        (scope) => scope.setUser(SentryUser(username: member.displayName)),
      );
      emit(FullMemberState.result(result: member));
    } on ApiException catch (exception) {
      emit(FullMemberState.failure(message: exception.message));
    }
  }

  Future<void> updateAvatar(CroppedFile file) async {
    await api.updateAvatar(file.path);
    await load();
  }

  Future<void> updateDescription(String description) async {
    await api.updateDescription(description);
    await load();
  }
}
