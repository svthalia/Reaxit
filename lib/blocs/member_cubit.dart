import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models/member.dart';

class MemberCubit extends Cubit<DetailState<Member>> {
  final ApiRepository api;

  MemberCubit(this.api) : super(DetailState<Member>.loading());

  void load(int pk) async {
    emit(state.copyWith(isLoading: true));
    try {
      final member = await api.getMember(pk: pk);
      emit(DetailState.result(result: member));
    } on ApiException catch (exception) {
      // TODO: give appropriate error message
      emit(DetailState.failure(message: 'An error occurred.'));
    }
  }
}
