import 'dart:async';

import 'package:reaxit/blocs/list_cubit.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';

typedef MemberListState = ListState<ListMember>;

class MemberListCubit extends SingleListCubit<ListMember> {
  MemberListCubit(super.api);

  static const int firstPageSize = 60;
  static const int pageSize = 30;

  int? year;

  @override
  Future<ListResponse<ListMember>> getDown(int offset) => api.getMembers(
        search: searchQuery,
        limit: offset == 0 ? firstPageSize : pageSize,
        offset: offset,
        year: year,
      );

  @override
  List<ListMember> combineDown(
          List<ListMember> downResults, ListState<ListMember> oldstate) =>
      oldstate.results + downResults;

  @override
  ListState<ListMember> empty(String? query) => switch (query) {
        null => const ListState.failure(message: 'No members found.'),
        '' => const ListState.failure(message: 'Start searching for members'),
        var q =>
          ListState.failure(message: 'No members found found for query "$q"'),
      };

  /// Set this cubit's `searchQuery` and load the albums for that query.
  ///
  /// Use `null` as argument to remove the search query.
  void filterYear(int? year) {
    if (year != this.year) {
      this.year = year;
      load();
    }
  }
}
