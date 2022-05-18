import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models/group.dart';

typedef BoardsState = DetailState<List<ListGroup>>;

class BoardsCubit extends Cubit<BoardsState> {
  final ApiRepository api;

  BoardsCubit(this.api) : super(const BoardsState.loading());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final listResponse = await api.getGroups(
        limit: 1000,
        type: MemberGroupType.board,
      );
      if (listResponse.results.isNotEmpty) {
        emit(BoardsState.result(result: listResponse.results));
      } else {
        emit(const BoardsState.failure(message: 'There are no boards.'));
      }
    } on ApiException catch (exception) {
      emit(BoardsState.failure(message: _failureMessage(exception)));
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
