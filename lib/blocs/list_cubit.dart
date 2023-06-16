import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/config.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';

abstract class ListCubit<T, S> extends Cubit<S> {
  final ApiRepository api;

  /// The last used search query. Can be set through `this.search(query)`.
  String? searchQuery;

  /// The offset to be used for the next paginated request.
  int _nextOffsetUp = 0;
  int _nextOffsetDown = 0;

  /// A timer used to debounce calls to `this.load()` from `this.search()`.
  Timer? _searchDebounceTimer;

  ListCubit(this.api, S state) : super(state);

  Future<void> load() async {
    final query = searchQuery;
    _nextOffsetUp = 0;
    _nextOffsetDown = 0;
    ListResponse<T> upResponse;
    ListResponse<T> downResponse;
    try {
      Future<ListResponse<T>> upResultsFuture = getUp(_nextOffsetUp);
      Future<ListResponse<T>> downResultsFuture = getDown(_nextOffsetDown);
      cleanupOldState();
      upResponse = await upResultsFuture;
      downResponse = await downResultsFuture;
    } on ApiException catch (exception) {
      emit(failure(exception.message));
      return;
    }

    // Discard result if _searchQuery has
    // changed since the request was made.
    if (query != searchQuery) return;

    _nextOffsetUp = upResponse.results.length;
    _nextOffsetDown = downResponse.results.length;

    final isDoneUp = _nextOffsetUp == upResponse.count;
    final isDoneDown = _nextOffsetDown == downResponse.count;

    List<T> upResults = processUp(upResponse.results);
    List<T> downResults = processDown(downResponse.results);

    (upResults: upResults, downResults: downResults) =
        shuffleData(upResults, downResults);

    upResults = filterUp(upResults);
    downResults = filterDown(downResults);

    if (upResults.isEmpty && downResults.isEmpty) {
      emit(empty(query ?? ''));
    } else {
      emit(newState(
          resultsUp: upResults,
          resultsDown: downResults,
          isDoneUp: isDoneUp,
          isDoneDown: isDoneDown));
    }
  }

  Future<void> moreDown() async {
    final oldState = state;
    final query = searchQuery;

    // Ignore calls to `more()` if there is no data, or already more coming.
    if (supressMoreDown(oldState)) {
      return;
    }

    emit(loadingDown(oldState));

    ListResponse<T> downResponse;
    try {
      Future<ListResponse<T>> downResultsFuture = getDown(_nextOffsetDown);
      downResponse = await downResultsFuture;
    } on ApiException catch (exception) {
      emit(failure(exception.message));
      return;
    }

    // Discard result if _searchQuery has
    // changed since the request was made.
    if (query != searchQuery) return;

    _nextOffsetDown += downResponse.results.length;
    final isDoneDown = _nextOffsetDown == downResponse.count;

    List<T> downResults = processDown(downResponse.results);
    downResults = filterDown(downResults);

    final totalDownResults = combineDown(downResults, oldState);

    emit(updateDown(oldState, totalDownResults, isDoneDown));
  }

  Future<void> moreUp() async {
    final oldState = state;
    final query = searchQuery;

    // Ignore calls to `more()` if there is no data, or already more coming.
    if (supressMoreUp(oldState)) {
      return;
    }

    emit(loadingUp(oldState));

    ListResponse<T> upResponse;
    try {
      Future<ListResponse<T>> downResultsFuture = getUp(_nextOffsetUp);
      upResponse = await downResultsFuture;
    } on ApiException catch (exception) {
      emit(failure(exception.message));
      return;
    }

    // Discard result if _searchQuery has
    // changed since the request was made.
    if (query != searchQuery) return;

    _nextOffsetUp += upResponse.results.length;
    final isDoneUp = _nextOffsetUp == upResponse.count;

    List<T> downResults = processUp(upResponse.results);
    downResults = filterUp(downResults);

    final totalUpResults = combineUp(downResults, oldState);

    emit(updateUp(oldState, totalUpResults, isDoneUp));
  }

  /// Set this cubit's `searchQuery` and load the albums for that query.
  ///
  /// Use `null` as argument to remove the search query.
  void search(String? query) {
    if (query != searchQuery) {
      searchQuery = query;
      _searchDebounceTimer?.cancel();
      if (query?.isEmpty ?? false) {
        /// Don't get results when the query is empty.
        emit(loading());
      } else {
        _searchDebounceTimer = Timer(Config.searchDebounceTime, load);
      }
    }
  }

  Future<ListResponse<T>> getUp(int offset);
  Future<ListResponse<T>> getDown(int offset);

  // This is called when a new load is triggered (after the API is called)
  void cleanupOldState() => {};

  List<T> processUp(List<T> upResults) => upResults;
  List<T> processDown(List<T> downResults) => downResults;

  // This is supposed to resolve some issues around the up/down boundry.
  // For example, when some results from up should be moved to down, this can be overwritten.
  ({List<T> upResults, List<T> downResults}) shuffleData(
          List<T> upResults, List<T> downResults) =>
      (upResults: upResults, downResults: downResults);

  List<T> filterUp(List<T> upResults) => upResults;
  List<T> filterDown(List<T> downResults) => downResults;

  List<T> combineUp(List<T> upResults, S oldstate);
  List<T> combineDown(List<T> downResults, S oldstate);

  bool supressMoreUp(S oldstate);
  bool supressMoreDown(S oldstate);

  S loading();
  S loadingUp(S oldstate);
  S loadingDown(S oldstate);
  S empty(String query);
  S failure(String message);
  S newState({
    List<T> resultsUp = const [],
    List<T> resultsDown = const [],
    required bool isDoneUp,
    required bool isDoneDown,
  });
  S updateUp(S oldstate, List<T> upResults, bool isDoneUp);
  S updateDown(S oldstate, List<T> downResults, bool isDoneDown);
}

abstract class SingleListCubit<T> extends ListCubit<T, ListState<T>> {
  SingleListCubit(ApiRepository api)
      : super(api, const ListState.loading(results: []));

  @override
  Future<ListResponse<T>> getUp(int offset) async => ListResponse<T>(0, []);

  @override
  List<T> combineUp(List<T> upResults, ListState oldstate) => upResults;

  @override
  bool supressMoreUp(ListState oldstate) => true;

  @override
  bool supressMoreDown(ListState oldstate) =>
      oldstate.isDone || oldstate.isLoading || oldstate.isLoadingMore;

  @override
  ListState<T> loading() => const ListState.loading(results: []);

  @override
  ListState<T> loadingUp(ListState<T> oldstate) => oldstate;

  @override
  ListState<T> loadingDown(ListState<T> oldstate) =>
      oldstate.copyWith(isLoadingMore: true);

  @override
  ListState<T> failure(String message) => ListState.failure(message: message);

  @override
  ListState<T> newState({
    List<T> resultsUp = const [],
    List<T> resultsDown = const [],
    required bool isDoneUp,
    required bool isDoneDown,
  }) =>
      ListState.success(results: resultsDown, isDone: isDoneDown);

  @override
  ListState<T> updateUp(
          ListState<T> oldstate, List<T> upResults, bool isDoneUp) =>
      oldstate;

  @override
  ListState<T> updateDown(
          ListState<T> oldstate, List<T> downResults, bool isDoneDown) =>
      oldstate.copyWith(results: downResults, isDone: isDoneDown);

  Future<void> more() => moreDown();
}
