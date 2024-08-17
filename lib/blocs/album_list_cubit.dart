import 'dart:async';

import 'package:reaxit/blocs/list_cubit.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';

typedef AlbumListState = ListState<ListAlbum>;

class AlbumListCubit extends SingleListCubit<ListAlbum> {
  AlbumListCubit(super.api);

  static const int firstPageSize = 30;

  @override
  Future<ListResponse<ListAlbum>> getDown(int offset) => api.getAlbums(
        search: searchQuery,
        limit: firstPageSize,
        offset: offset,
      );

  @override
  List<ListAlbum> combineDown(
          List<ListAlbum> downResults, ListState<ListAlbum> oldstate) =>
      oldstate.results + downResults;

  @override
  ListState<ListAlbum> empty(String? query) => switch (query) {
        null => const ListState.failure(message: 'No albums found.'),
        '' => const ListState.failure(message: 'Start searching for albums'),
        var q =>
          ListState.failure(message: 'No albums found found for query "$q"'),
      };
}
