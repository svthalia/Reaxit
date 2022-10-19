import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models/group.dart';

typedef GroupsState = DetailState<List<ListGroup>>;

class GroupsCubit extends  Cubit<GroupsState> {
  final ApiRepository api;
  final MemberGroupType? groupType;

  GroupsCubit(this.api, this.groupType) : super(const GroupsState.loading());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final listResponse = await api.getGroups(
        limit: 1000,
        type: groupType
      );
      if (listResponse.results.isNotEmpty) {
        emit(GroupsState.result(result: listResponse.results));
      } else {
        emit(const GroupsState.failure(message: 'There are no boards.'));
      }
    } on ApiException catch (exception) {
      emit(GroupsState.failure(message: _failureMessage(exception)));
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

class BoardsCubit extends GroupsCubit {
  BoardsCubit(ApiRepository api) : super(api, MemberGroupType.board);
}

class CommitteesCubit extends GroupsCubit {
  CommitteesCubit(ApiRepository api) : super(api, MemberGroupType.committee);
}

class SocietiesCubit extends GroupsCubit {
  SocietiesCubit(ApiRepository api) : super(api, MemberGroupType.society);
}