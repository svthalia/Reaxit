import 'dart:async';

import 'package:reaxit/blocs/list_cubit.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/models/thabloid.dart';

typedef ThabloidListState = InnerListState<Thabloid>;

class ThabloidListCubit extends SingleListCubit<Thabloid> {
  ThabloidListCubit(super.api);

  static const int firstPageSize = 30;

  @override
  Future<ListResponse<Thabloid>> getDown(int offset) => api.getThabloids(
    search: searchQuery,
    limit: firstPageSize,
    offset: offset,
  );

  @override
  List<Thabloid> combineDown(
    List<Thabloid> downResults,
    ListState<Thabloid> oldstate,
  ) => getResults(oldstate) + downResults;

  @override
  ListState<Thabloid> empty(String? query) {
    return const ErrorState('No thabloids found.');
  }
}
