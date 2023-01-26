import 'dart:async';

import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs/list_state.dart';
import 'package:reaxit/config.dart' as config;
import 'package:reaxit/models.dart';
import 'package:reaxit/ui/widgets.dart';

class AlbumListCubit extends PaginatedCubit<ListAlbum> {
  final ApiRepository api;

  /// The last used search query. Can be set through `this.search(query)`.
  String? _searchQuery;

  /// The last used search query. Can be set through `this.search(query)`.
  String? get searchQuery => _searchQuery;

  /// A timer used to debounce calls to `this.load()` from `this.search()`.
  Timer? _searchDebounceTimer;

  /// The offset to be used for the next paginated request.
  int _nextOffset = 0;

  AlbumListCubit(this.api) : super(firstPageSize: 60, pageSize: 30);

  @override
  Future<void> load() async {
    try {
      final query = _searchQuery;
      final albumsResponse = await api.getAlbums(
        search: query,
        limit: firstPageSize,
        offset: 0,
      );

      // Discard result if _searchQuery has
      // changed since the request was made.
      if (query != _searchQuery) return;

      final isDone = albumsResponse.results.length == albumsResponse.count;

      _nextOffset = firstPageSize;

      if (albumsResponse.results.isEmpty) {
        if (query?.isEmpty ?? true) {
          emit(const ErrorListState('There are no albums.'));
        } else {
          emit(ErrorListState('There are no albums found for "$query".'));
        }
      } else {
        emit(ResultsListState.withDone(albumsResponse.results, isDone));
      }
    } on ApiException catch (exception) {
      emit(ErrorListState(exception.message));
    }
  }

  @override
  Future<void> more() async {
    // Ignore calls to `more()` if there is no data, or already more coming.
    if (state is! ResultsListState ||
        state is LoadingMoreListState ||
        state is DoneListState) return;

    final oldState = state as ResultsListState<ListAlbum>;

    emit(LoadingMoreListState.from(oldState));
    try {
      final query = _searchQuery;

      // Get next page of albums.
      final albumsResponse = await api.getAlbums(
        search: query,
        limit: pageSize,
        offset: _nextOffset,
      );

      // Discard result if _searchQuery has
      // changed since the request was made.
      if (query != _searchQuery) return;

      final albums = state.results + albumsResponse.results;
      final isDone = albums.length == albumsResponse.count;

      _nextOffset += pageSize;

      emit(ResultsListState.withDone(albums, isDone));
    } on ApiException catch (exception) {
      emit(ErrorListState(exception.getMessage()));
    }
  }

  /// Set this cubit's `searchQuery` and load the albums for that query.
  ///
  /// Use `null` as argument to remove the search query.
  void search(String? query) {
    if (query != _searchQuery) {
      _searchQuery = query;
      _searchDebounceTimer?.cancel();
      if (query?.isEmpty ?? false) {
        /// Don't get results when the query is empty.
        emit(const LoadingListState());
      } else {
        _searchDebounceTimer = Timer(config.searchDebounceTime, load);
      }
    }
  }
}
