import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/config.dart' as config;
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';

abstract class ListCubit<T> extends Cubit<ListState<T>> {
  final ApiRepository api;

  /// The last used search query. Can be set through `this.search(query)`.
  String? searchQuery;


  // TODO: force implementors to set these somehow?
  int firstPageSizeUp = 0;
  int firstPageSizeDown = 0;

  /// The offset to be used for the next paginated request.
  int _nextOffsetUp = 0;
  int _nextOffsetDown = 0;

  ListCubit(this.api) : super(const ListState.loading(results: []));
  /// A timer used to debounce calls to `this.load()` from `this.search()`.
  Timer? _searchDebounceTimer;

  Future<void> load() async {
    final query = searchQuery;
    ListResponse<T> upResponse;
    ListResponse<T> downResponse;
    try{
      Future<ListResponse<T>> upResultsFuture = getUp();
      Future<ListResponse<T>> downResultsFuture = getDown();
      cleanupOldState();
      upResponse = await upResultsFuture;
      downResponse = await downResultsFuture;
    } on ApiException catch (exception) {
      emit(ListState.failure(message: exception.message));
      return;
    }

    // Discard result if _searchQuery has
    // changed since the request was made.
    if (query != searchQuery) return;
  
    _nextOffsetUp = firstPageSizeUp;
    _nextOffsetDown = firstPageSizeDown;

    final isDoneDown =
          upResponse.results.length == upResponse.count;
    final isDoneUp =
          downResponse.results.length == downResponse.count;

    List<T> upResults = processUp(upResponse.results);
    List<T> downResults = processUp(downResponse.results);

    (upResults: upResults, downResults: downResults) = shuffleData(upResults, downResults);

    upResults = filterUp(upResults);
    downResults = filterDown(downResults);

    // TODO: handle errors and emit results
  }

  Future<void> moreDown() async {
    final oldState = state;
    final query = searchQuery;

    // TODO: we need a 2 way ListState first
    // Ignore calls to `more()` if there is no data, or already more coming.
    // if (oldState.isDoneDown ||
    //     oldState.isLoading ||
    //     oldState.isLoadingMoreDown) {
    //   return;
    // }

    ListResponse<T> downResponse;
    try{
      Future<ListResponse<T>> downResultsFuture = getUp();
      downResponse = await downResultsFuture;
    } on ApiException catch (exception) {
      emit(ListState.failure(message: exception.message));
      return;
    }

    // Discard result if _searchQuery has
    // changed since the request was made.
    if (query != searchQuery) return;

    final isDoneDown =
          _nextOffsetDown + downResponse.results.length == downResponse.count;

    List<T> upResults = processDown(downResponse.results);
    upResults = filterDown(upResults);

    final totalUpResults = oldState.results + upResults;
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
        _searchDebounceTimer = Timer(config.searchDebounceTime, load);
      }
    }
  }
  
  Future<ListResponse<T>> getUp();
  Future<ListResponse<T>> getDown();

  // This is called when a new load is triggered (after the API is called)
  void cleanupOldState() => {};

  List<T> processUp(List<T> upResults);
  List<T> processDown(List<T> downResults);

  // This is supposed to resolve some issues around the up/down boundry.
  // For example, when some results from up should be moved to down, this can be overwritten.
  ({List<T> upResults, List<T> downResults}) shuffleData(List<T> upResults, List<T> downResults) => (upResults: upResults, downResults: downResults);

  List<T> filterUp(List<T> upResults);
  List<T> filterDown(List<T> downResults);
}
