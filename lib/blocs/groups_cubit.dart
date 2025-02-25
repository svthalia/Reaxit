import 'dart:async';

import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/blocs/list_cubit.dart';
import 'package:reaxit/models.dart';

typedef GroupsState = ListState<ListGroup>;

class GroupsCubit extends SingleListCubit<ListGroup> {
  final MemberGroupType? groupType;

  GroupsCubit(super.api, this.groupType);

  @override
  List<ListGroup> combineDown(
    List<ListGroup> downResults,
    ListState<ListGroup> oldstate,
  ) => oldstate.results + downResults;

  @override
  ListState<ListGroup> empty(String? query) => switch (query) {
    null => const ListState.failure(message: 'No groups found.'),
    '' => const ListState.failure(message: 'Start searching for groups'),
    var q => ListState.failure(message: 'No groups found found for query "$q"'),
  };

  @override
  Future<ListResponse<ListGroup>> getDown(int offset) => api.getGroups(
    limit: 1000,
    offset: offset,
    type: groupType,
    search: searchQuery,
  );

  @override
  List<ListGroup> processDown(List<ListGroup> downResults) {
    if (downResults.first.type == MemberGroupType.board) {
      downResults = downResults.reversed.toList();
    }
    return downResults;
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

class AllGroupsCubit extends GroupsCubit {
  // We pass null as MemberGroupType, so we get all groups.
  AllGroupsCubit(ApiRepository api) : super(api, null);
}
