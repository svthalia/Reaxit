import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models/group.dart';

class CommitteesCubit extends Cubit<DetailState<List<ListGroup>>> {
  final ApiRepository api;

  CommitteesCubit(this.api)
      : super(const DetailState<List<ListGroup>>.loading());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final listResponse = await api.getGroups(
          limit: 1000, offset: 0, type: MemberGroupType.committee);
      if (listResponse.results.isNotEmpty) {
        emit(DetailState.result(result: listResponse.results));
      } else {
        emit(const DetailState.failure(message: 'There are no committees.'));
      }
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
