import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';

typedef GroupState = DetailState<Group>;

abstract class BaseGroupCubit {
  Future<void> load();
}

class GroupCubit extends Cubit<GroupState> implements BaseGroupCubit {
  final ApiRepository api;
  final int pk;

  GroupCubit(this.api, {required this.pk}) : super(const GroupState.loading());

  @override
  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final group = await api.getGroup(pk: pk);
      emit(DetailState.result(result: group));
    } on ApiException catch (exception) {
      emit(DetailState.failure(
        message: exception.getMessage(
          notFound: 'The group does not exist.',
        ),
      ));
    }
  }
}

class BoardCubit extends Cubit<GroupState> implements BaseGroupCubit {
  final ApiRepository api;
  final int since;
  final int until;

  BoardCubit(this.api, {required this.since, required this.until})
      : super(const GroupState.loading());

  @override
  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final group = await api.getBoardGroup(since: since, until: until);
      emit(DetailState.result(result: group));
    } on ApiException catch (exception) {
      emit(DetailState.failure(
        message: exception.getMessage(
          notFound: 'The group does not exist.',
        ),
      ));
    }
  }
}
