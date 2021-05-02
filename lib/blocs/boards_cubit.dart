import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models/group.dart';

class BoardsCubit extends Cubit<DetailState<List<ListGroup>>> {
  final ApiRepository api;

  BoardsCubit(this.api) : super(DetailState<List<ListGroup>>.loading());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final listResponse = await api.getBoards();
      if (listResponse.results.isNotEmpty) {
        emit(DetailState.result(result: listResponse.results));
      } else {
        emit(DetailState.failure(message: 'There are no boards.'));
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
