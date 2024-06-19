import 'dart:async';

import 'package:reaxit/blocs/list_cubit.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';

typedef MemberListState = ListState<ListMember>;

class MemberListCubit extends SingleListCubit<ListMember> {
  MemberListCubit(super.api);

  static const int firstPageSize = 60;
  static const int pageSize = 30;

  @override
  Future<ListResponse<ListMember>> getDown(int offset) => api.getMembers(
        search: searchQuery,
        limit: offset == 0 ? firstPageSize : pageSize,
        offset: offset,
      );

  @override
  List<ListMember> combineDown(
          List<ListMember> downResults, ListState<ListMember> oldstate) =>
      oldstate.results + downResults;

  @override
  ListState<ListMember> empty(String query) {
    if (query.isEmpty) {
      return const ListState.failure(message: 'No members found.');
    } else {
      return ListState.failure(
          message: "No members found found with for '$query'");
    }
  }
}
