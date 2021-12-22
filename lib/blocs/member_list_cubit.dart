import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api_repository.dart';
import 'package:reaxit/config.dart' as config;
import 'package:reaxit/blocs/list_state.dart';
import 'package:reaxit/models/member.dart';

typedef MemberListState = ListState<ListMember>;

class MemberListCubit extends Cubit<MemberListState> {
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

  MemberListCubit(this.api) : super(const MemberListState.loading(results: []));

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final query = _searchQuery;
      final membersResponse = await api.getMembers(
        search: query,
        limit: firstPageSize,
        offset: 0,
      );

      // Discard result if _searchQuery has
      // changed since the request was made.
      if (query != _searchQuery) return;

      final isDone = membersResponse.results.length == membersResponse.count;

      _nextOffset = firstPageSize;

      if (membersResponse.results.isEmpty) {
        if (query?.isEmpty ?? true) {
          emit(const MemberListState.failure(message: 'There are no members.'));
        } else {
          emit(MemberListState.failure(
            message: 'There are no members found for "$query".',
          ));
        }
      } else {
        emit(MemberListState.success(
          results: membersResponse.results,
          isDone: isDone,
        ));
      }
    } on ApiException catch (exception) {
      emit(MemberListState.failure(message: _failureMessage(exception)));
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
      final membersResponse = await api.getMembers(
        search: query,
        limit: pageSize,
        offset: _nextOffset,
      );

      // Discard result if _searchQuery has
      // changed since the request was made.
      if (query != _searchQuery) return;

      final members = state.results + membersResponse.results;
      final isDone = members.length == membersResponse.count;

      _nextOffset += pageSize;

      emit(MemberListState.success(
        results: members,
        isDone: isDone,
      ));
    } on ApiException catch (exception) {
      emit(MemberListState.failure(message: _failureMessage(exception)));
    }
  }

  /// Set this cubit's `searchQuery` and load the members for that query.
  ///
  /// Use `null` as argument to remove the search query.
  void search(String? query) {
    if (query != _searchQuery) {
      _searchQuery = query;
      _searchDebounceTimer?.cancel();
      if (query?.isEmpty ?? false) {
        /// Don't get results when the query is empty.
        emit(const MemberListState.loading(results: []));
      } else {
        _searchDebounceTimer = Timer(config.searchDebounceTime, load);
      }
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
