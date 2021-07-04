import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api_repository.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models/member.dart';

typedef MemberState = DetailState<Member>;

class MemberCubit extends Cubit<MemberState> {
  final ApiRepository api;

  MemberCubit(this.api) : super(MemberState.loading());

  Future<void> load(int pk) async {
    emit(state.copyWith(isLoading: true));
    try {
      final member = await api.getMember(pk: pk);
      emit(MemberState.result(result: member));
    } on ApiException catch (exception) {
      emit(MemberState.failure(message: _failureMessage(exception)));
    }
  }

  String _failureMessage(ApiException exception) {
    switch (exception) {
      case ApiException.noInternet:
        return 'Not connected to the internet.';
      case ApiException.notFound:
        return 'The member does not exist.';
      default:
        return 'An unknown error occurred.';
    }
  }
}
