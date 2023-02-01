import 'dart:async';

import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/config.dart' as config;
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/ui/widgets.dart';

class MemberListCubit extends PaginatedCubit<ListMember> {
  final ApiRepository api;

  /// The last used search query. Can be set through `this.search(query)`.
  String? _searchQuery;

  /// The last used search query. Can be set through `this.search(query)`.
  String? get searchQuery => _searchQuery;

  /// A timer used to debounce calls to `this.load()` from `this.search()`.
  Timer? _searchDebounceTimer;

  /// The offset to be used for the next paginated request.
  int _nextOffset = 0;

  MemberListCubit(this.api) : super(firstPageSize: 60, pageSize: 30);

  @override
  Future<void> load() async {
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
          emit(const ErrorListState('There are no members.'));
        } else {
          emit(ErrorListState('There are no members found for "$query".'));
        }
      } else {
        emit(ResultsListState.withDone(membersResponse.results, isDone));
      }
    } on ApiException catch (exception) {
      emit(ErrorListState(exception.message));
    }
  }

  @override
  Future<void> more() async {
    // Ignore calls to `more()` if there is no data, or already more coming.
    final oldState = state;
    if (oldState is! ResultsListState ||
        oldState is LoadingMoreListState ||
        oldState is DoneListState) return;

    final resultsState = oldState as ResultsListState<ListMember>;

    emit(LoadingMoreListState.from(resultsState));
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

      final members = resultsState.results + membersResponse.results;
      final isDone = members.length == membersResponse.count;

      _nextOffset += pageSize;

      emit(ResultsListState.withDone(members, isDone));
    } on ApiException catch (exception) {
      emit(ErrorListState(exception.getMessage()));
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
        emit(const LoadingListState());
      } else {
        _searchDebounceTimer = Timer(config.searchDebounceTime, load);
      }
    }
  }
}
