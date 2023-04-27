import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/config.dart' as config;
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';

typedef AlbumListState = ListState<ListAlbum>;

/// The state manager for the [AlbumsScreen] screen.
///
/// When [load]ed, fetches the albums matching [_searchQuery] from [api].
/// Also has [more] for loading additional pages and [search] to reload with a different [_searchQuery].
class AlbumListCubit extends Cubit<AlbumListState> {
  /// The amount of albums displayed on [load].
  static const int firstPageSize = 60;

  /// The amount of additional albums displayed on [more].
  static const int pageSize = 30;

  final ApiRepository api;

  /// The last used search query. Can be set through `this.search(query)`.
  String? _searchQuery;

  /// The last used search query. Can be set through `this.search(query)`.
  String? get searchQuery => _searchQuery;

  /// A timer used to debounce calls to `this.load()` from `this.search()`.
  Timer? _searchDebounceTimer;

  /// The offset to be used for the next paginated request.
  int _nextOffset = 0;

  AlbumListCubit(this.api) : super(const AlbumListState.loading(results: []));

  /// Initializes [state] to proper `success` [AlbumListState] for [AlbumsScreen] by fetching the first [firstPageSize] albums matching [_searchQuery] from [api].
  ///
  /// [state] defaults to `loading` [AlbumListState] while waiting for a response from [api].
  /// Does nothing if [_searchQuery] was changed before the [api] responded.
  /// Updates [state] to `failure` [AlbumListState] with relevant message if no albums exist, no album matches [_searchQuery], or upon [ApiException].
  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
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
          emit(const AlbumListState.failure(message: 'There are no albums.'));
        } else {
          emit(AlbumListState.failure(
            message: 'There are no albums found for "$query".',
          ));
        }
      } else {
        emit(AlbumListState.success(
          results: albumsResponse.results,
          isDone: isDone,
        ));
      }
    } on ApiException catch (exception) {
      emit(AlbumListState.failure(message: exception.message));
    }
  }

  /// Updates [state] to proper `success` [AlbumListState] for [AlbumsScreen] by fetching [pageSize] more unloaded albums matching [_searchQuery] from [api].
  ///
  /// [state] defaults to `loadingMore` [AlbumListState] while waiting for a response from [api].
  /// Does nothing if [_searchQuery] was changed before the [api] responded.
  /// Updates [state] to `failure` [AlbumListState] on [ApiException].
  Future<void> more() async {
    final oldState = state;

    // Ignore calls to `more()` if there is no data, or already more coming.
    if (oldState.isDone || oldState.isLoading || oldState.isLoadingMore) return;

    emit(oldState.copyWith(isLoadingMore: true));
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

      emit(AlbumListState.success(
        results: albums,
        isDone: isDone,
      ));
    } on ApiException catch (exception) {
      emit(AlbumListState.failure(message: exception.message));
    }
  }

  /// Sets [_searchQuery] to [query] and [load]s the albums matching [query].
  ///
  /// Does nothing if [query] is equal to [_searchQuery].
  /// Clears [_searchQuery] if [query] is `null`.
  /// Updates [state] to `loading` [AlbumListState] if [query] is empty.
  void search(String? query) {
    if (query != _searchQuery) {
      _searchQuery = query;
      _searchDebounceTimer?.cancel();
      if (query?.isEmpty ?? false) {
        /// Don't get results when the query is empty.
        emit(const AlbumListState.loading(results: []));
      } else {
        _searchDebounceTimer = Timer(config.searchDebounceTime, load);
      }
    }
  }
}
