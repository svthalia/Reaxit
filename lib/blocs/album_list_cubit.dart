import 'dart:async';

import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/config.dart';
import 'package:reaxit/blocs/list_cubit.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';

typedef AlbumListState = ListState<ListAlbum>;

class AlbumListCubit extends SingleListCubit<ListAlbum> {
  AlbumListCubit(ApiRepository api) : super(api);

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
  ListState<ListAlbum> empty(String query) {
    if (query.isEmpty) {
      return const ListState.failure(message: 'No albums found.');
    } else {
      return ListState.failure(message: 'No albums found for query $query.');
    }
  }
}
