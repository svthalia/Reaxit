import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';

typedef MemberState = DetailState<Member>;

class MemberCubit extends Cubit<MemberState> {
  final ApiRepository api;

  MemberCubit(this.api) : super(const MemberState.loading());

  Future<void> load(int pk) async {
    emit(state.copyWith(isLoading: true));
    try {
      final member = await api.getMember(pk: pk);
      emit(MemberState.result(result: member));
    } on ApiException catch (exception) {
      emit(MemberState.failure(
        message: exception.getMessage(notFound: 'The member does not exist.'),
      ));
    }
  }
}
