import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models/group.dart';

class GroupCubit extends Cubit<DetailState<Group>> {
  final ApiRepository api;

  GroupCubit(this.api) : super(DetailState<Group>.loading());

  Future<void> load(int pk) async {
    emit(state.copyWith(isLoading: true));
    try {
      final group = await api.getGroup(pk: pk);
      emit(DetailState.result(result: group));
    } on ApiException catch (exception) {
      emit(DetailState.failure(message: _failureMessage(exception)));
    }
  }

  String _failureMessage(ApiException exception) {
    switch (exception) {
      case ApiException.noInternet:
        return 'Not connected to the internet.';
      case ApiException.notFound:
        return 'The group does not exist.';
      default:
        return 'An unknown error occurred.';
    }
  }
}
