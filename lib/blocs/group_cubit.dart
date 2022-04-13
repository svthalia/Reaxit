import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models/group.dart';

typedef GroupState = DetailState<Group>;

class GroupCubit extends Cubit<GroupState> {
  final ApiRepository api;
  final int pk;

  GroupCubit(this.api, {required this.pk})
      : super(const DetailState<Group>.loading());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final groupResponse = await api.getGroup(pk: pk);
      emit(DetailState.result(result: groupResponse));
    } on ApiException catch (exception) {
      emit(DetailState.failure(message: _failureMessage(exception)));
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
