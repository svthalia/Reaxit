import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';

typedef GroupState = DetailState<Group>;

class GroupCubit extends Cubit<GroupState> {
  final ApiRepository api;
  final int pk;

  GroupCubit(this.api, {required this.pk}) : super(const LoadingState());

  Future<void> load() async {
    emit(LoadingState.from(state));
    try {
      final group = await api.getGroup(pk: pk);
      emit(ResultState(group));
    } on ApiException catch (exception) {
      emit(ErrorState(exception.getMessage(
        notFound: 'The group does not exist.',
      )));
    }
  }
}
