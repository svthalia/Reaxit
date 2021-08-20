import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api_repository.dart';
import 'package:reaxit/config.dart' as config;
import 'package:reaxit/blocs/list_state.dart';
import 'package:reaxit/models/album.dart';

typedef AlbumListState = ListState<ListAlbum>;

class AlbumListCubit extends Cubit<AlbumListState> {
  static const int firstPageSize = 60;
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

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final query = _searchQuery;
      var albumsResponse = await api.getAlbums(
        search: query,
        limit: firstPageSize,
        offset: 0,
      );

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
      emit(AlbumListState.failure(message: _failureMessage(exception)));
    }
  }

  Future<void> more() async {
    final _state = state;

    // Ignore calls to `more()` if there is no data, or already more coming.
    if (_state.isDone || _state.isLoading || _state.isLoadingMore) return;

    emit(_state.copyWith(isLoadingMore: true));
    try {
      final query = _searchQuery;

      // Get next page of albums.
      var albumsResponse = await api.getAlbums(
        search: query,
        limit: pageSize,
        offset: _nextOffset,
      );

      final albums = state.results + albumsResponse.results;
      final isDone = albums.length == albumsResponse.count;

      _nextOffset += pageSize;

      emit(AlbumListState.success(
        results: albums,
        isDone: isDone,
      ));
    } on ApiException catch (exception) {
      emit(AlbumListState.failure(message: _failureMessage(exception)));
    }
  }

  /// Set this cubit's `searchQuery` and load the albums for that query.
  ///
  /// Use `null` as argument to remove the search query.
  void search(String? query) {
    if (query != _searchQuery) {
      _searchQuery = query;
      _searchDebounceTimer?.cancel();
      _searchDebounceTimer = Timer(config.searchDebounceTime, load);
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