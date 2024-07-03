import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/config.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';

abstract class ListCubitSource<T, D> {
  bool isDoneUp = false;
  bool isDoneDown = false;

  //// The offset to be used for the next paginated request.
  int _nextOffsetUp = 0;
  int _nextOffsetDown = 0;

  /// getUp wraps getUpi
  Future<List<D>> moreUp() {
    Future<ListResponse<T>> res = getUpi(_nextOffsetUp);
    return res.then((response) {
      _nextOffsetUp += response.results.length;
      isDoneUp = _nextOffsetUp == response.count;
      return processUp(response.results);
    });
  }

  /// getDown wraps getDowni
  Future<List<D>> moreDown() {
    Future<ListResponse<T>> res = getDowni(_nextOffsetDown);
    return res.then((response) {
      _nextOffsetDown += response.results.length;
      isDoneDown = _nextOffsetDown == response.count;
      return processDown(response.results);
    });
  }

  /// getUpi returns a future with more data in the up direction.
  /// This is where you would want to do an http request for example.
  Future<ListResponse<T>> getUpi(int offset);

  /// getDowni returns a future with more data in the down direction
  /// This is where you would want to do an http request for example.
  Future<ListResponse<T>> getDowni(int offset);

  /// processUp processes the data in the up direction. May also filter
  /// out data
  List<D> processUp(List<T> results);

  /// processDown processes the data in the up direction. May also filter
  /// out data
  List<D> processDown(List<T> results);
}

/// This is an abstract `Cubit`, which needs to be implemented by other classes.
/// If a class implements all the methods of `ListCubit`, it is a Cubit.
/// Since there are a lot of methods to implement, and most `ListCubit`s will be
/// one-way only, users should probably implement `SingleListCubit` instead.
abstract class ListCubit<F, T, S> extends Cubit<S> {
  final ApiRepository api;

  late List<ListCubitSource<dynamic, T>> sources = [];

  //// The last used search query. Can be set through `this.search(query)`.
  String? searchQuery;

  //// A timer used to debounce calls to from `this.search()`.
  Timer? _searchDebounceTimer;

  /// Debouncetimer to fix things like load
  Timer? _debounceTimer;

  ListCubit(this.api, S state) : super(state);

  // Initial load the the data, but only fetches new data if the debounce timer
  // is done.
  Future<void> cachedLoad() async {
    if (_debounceTimer == null || !_debounceTimer!.isActive) {
      await load();
    }
  }

  /// Initial load of the data, resets all the state and loads data in both ways.
  /// This follows a couple steps
  Future<void> load() async {
    final query = searchQuery;

    _debounceTimer = Timer(const Duration(minutes: 10), () => {});

    // Get the data in both directions
    List<Future<List<T>>> futuresUp = [];
    List<Future<List<T>>> futuresDown = [];
    for (final source in sources) {
      source._nextOffsetDown = 0;
      source._nextOffsetUp = 0;
      futuresUp.add(source.moreUp());
      futuresDown.add(source.moreDown());
    }
    cleanupOldState();
    List<List<T>> resultsUp = [];
    List<List<T>> resultsDown = [];
    try {
      resultsUp = await Future.wait(futuresUp);
      resultsDown = await Future.wait(futuresDown);
    } on ApiException catch (exception) {
      _emit(failure(exception.message));
      return;
    }

    // Discard result if _searchQuery has
    // changed since the request was made.
    if (query != searchQuery) return;

    final isDoneUp = !sources.map((e) => e.isDoneUp).contains(false);
    final isDoneDown = !sources.map((e) => e.isDoneDown).contains(false);

    // Do any processing that needs to be done on the data
    List<T> upResults = mergeUp(resultsUp);
    List<T> downResults = mergeDown(resultsDown);

    // Allow the cubit to move data between up and down
    (upResults: upResults, downResults: downResults) =
        shuffleData(upResults, downResults);

    // Some cubits need to filter out certain results
    if (!isDoneUp) {
      upResults = filterUp(upResults);
    }
    if (!isDoneDown) {
      downResults = filterDown(downResults);
    }

    if (upResults.isEmpty && downResults.isEmpty) {
      _emit(empty(query ?? ''));
    } else {
      _emit(newState(
          resultsUp: upResults,
          resultsDown: downResults,
          isDoneUp: isDoneUp,
          isDoneDown: isDoneDown));
    }
  }

  /// moreDown loads more data in the down direction. For example when hitting
  /// the bottom when scrolling down. It follows the same prosedure as
  /// initial loading but only does half of it.
  Future<void> moreDown() async {
    final oldState = state;
    final query = searchQuery;

    // Ignore calls to `more()` if there is no data, or already more coming.
    if (!canLoadMoreDown(oldState)) {
      return;
    }

    _emit(loadingDown(oldState));

    // Get the data in the down direction
    List<List<T>> resultsDown = [];
    try {
      resultsDown = await Future.wait(
          sources.map((source) => source.moreDown()).toList());
    } on ApiException catch (exception) {
      _emit(failure(exception.message));
      return;
    }

    // Discard result if _searchQuery has
    // changed since the request was made.
    if (query != searchQuery) return;

    final isDoneDown = !sources.map((e) => e.isDoneDown).contains(false);

    List<T> downResults = mergeDown(resultsDown);
    if (!isDoneDown) {
      downResults = filterDown(downResults);
    }
    final totalDownResults = combineDown(downResults, oldState);

    _emit(updateDown(oldState, totalDownResults, isDoneDown));
  }

  /// moreUp loads more data in the up direction. For example when hitting
  /// the top when scrolling up. It follows the same prosedure as
  /// initial loading but only does half of it.
  Future<void> moreUp() async {
    final oldState = state;
    final query = searchQuery;

    // Ignore calls to `more()` if there is no data, or already more coming.
    if (!canLoadMoreUp(oldState)) {
      return;
    }

    _emit(loadingUp(oldState));

    // Get the data in the down direction
    List<List<T>> resultsUp = [];
    try {
      resultsUp =
          await Future.wait(sources.map((source) => source.moreUp()).toList());
    } on ApiException catch (exception) {
      _emit(failure(exception.message));
      return;
    }

    // Discard result if _searchQuery has
    // changed since the request was made.
    if (query != searchQuery) return;

    final isDoneUp = !sources.map((e) => e.isDoneUp).contains(false);

    List<T> upResults = mergeUp(resultsUp);
    if (!isDoneUp) {
      upResults = filterUp(upResults);
    }

    final totalUpResults = combineUp(upResults, oldState);

    _emit(updateUp(oldState, totalUpResults, isDoneUp));
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
        _emit(empty(query ?? ''));
      } else {
        _searchDebounceTimer = Timer(Config.searchDebounceTime, load);
      }
    }
  }

  void _emit(S state) {
    // Since functions cannot be interupted in dart(without await), and isolates
    // dont share memory. Thus we know there is no interuption between this check
    // and emiting the state
    if (isClosed) {
      return;
    }
    emit(state);
  }

  /// This is called when a new load is triggered (after the API is called)
  void cleanupOldState() => {};

  /// processUp is called after getUp, and is used to processUp the data.
  /// For example, this can split daturned calendar events into multiple events.
  List<T> processUp(List<F> upResults);

  /// processDown is called after getDown, and is used to processUp the data.
  /// For example, this can split daturned calendar events into multiple events.
  List<T> processDown(List<F> downResults);

  /// mergeUp combines the results from multiple data sources in one direction.
  List<T> mergeUp(List<List<T>> results);

  /// mergeDown combines the results from multiple data sources in one direction.
  List<T> mergeDown(List<List<T>> results);

  /// This is supposed to resolve issues around the up/down boundry.
  /// For example, when some results from up should be moved to down,
  /// this can be overwritten.
  ({List<T> upResults, List<T> downResults}) shuffleData(
          List<T> upResults, List<T> downResults) =>
      (upResults: upResults, downResults: downResults);

  /// filterUp filters results in the up direction.
  /// This can be used to remove data that should not (yet) be shown to
  /// the user.
  List<T> filterUp(List<T> upResults) => upResults;

  /// filterDown filters results in the down direction.
  /// This can be used to remove data that should not (yet) be shown to
  /// the user.
  List<T> filterDown(List<T> downResults) => downResults;

  /// combineUp merges the new data with the new data, for the final result
  List<T> combineUp(List<T> upResults, S oldstate);

  /// combineDown merges the new data with the new data, for the final result
  List<T> combineDown(List<T> downResults, S oldstate);

  /// canLoadMoreDown is called to check if more data can/should be loaded
  /// (in loadMoreUp). For example when there is no more data, or we are
  /// already loading more data.
  bool canLoadMoreDown(S oldstate);

  /// canLoadMoreUp is called to check if more data can/should be loaded
  /// (in loadMoreDown). For example when there is no more data, or we are
  /// already loading more data.
  bool canLoadMoreUp(S oldstate);

  /// loading returns a state to be used when loading fully new data
  S loading();

  /// loadingUp returns a state to be used when loading new data in the up direction
  S loadingUp(S oldstate);

  /// loadingDown returns a state to be used when loading new data in the down direction
  S loadingDown(S oldstate);

  /// empty returns a state to be used when showing there is no data
  S empty(String query);

  /// failure returns a state to be used when showing there was a failure
  S failure(String message);

  /// newState returns a fully new state to be used in load
  S newState({
    List<T> resultsUp = const [],
    List<T> resultsDown = const [],
    required bool isDoneUp,
    required bool isDoneDown,
  });

  /// updateUp returns a state to be used when there is new data in the
  /// up direction
  S updateUp(S oldstate, List<T> upResults, bool isDoneUp);

  /// updateDown returns a state to be used when there is new data in the
  /// down direction
  S updateDown(S oldstate, List<T> downResults, bool isDoneDown);
}

class SingleListCubitSource<T> extends ListCubitSource<T, T> {
  SingleListCubit<T> cubit;
  SingleListCubitSource(this.cubit);

  @override
  Future<ListResponse<T>> getDowni(int offset) => this.cubit.getDown(offset);

  @override
  Future<ListResponse<T>> getUpi(int offset) async => ListResponse<T>(0, []);

  @override
  List<T> processUp(List<T> results) => results;

  @override
  List<T> processDown(List<T> results) => results;
}

/// This class should be implemented when implementing a listcubit when only
/// needing to show data on one side (usually down). The methods you need to
/// overwrite are `getDown`, `combineDown`, and `empty`. This should makes it
/// trivial to implement a single ended ListCubit.
abstract class SingleListCubit<T> extends ListCubit<T, T, ListState<T>> {
  late final List<ListCubitSource<dynamic, T>> _sources = [
    SingleListCubitSource(this)
  ];

  @override
  List<ListCubitSource<dynamic, T>> get sources => _sources;

  SingleListCubit(ApiRepository api)
      : super(api, const ListState.loading(results: []));

  Future<ListResponse<T>> getDown(int offset);

  @override
  List<T> combineUp(List<T> upResults, ListState oldstate) => upResults;

  @override
  List<T> processDown(List<T> downResults) => downResults;

  @override
  List<T> processUp(List<T> upResults) => upResults;

  @override
  bool canLoadMoreDown(ListState oldstate) =>
      !oldstate.isDone && !oldstate.isLoading && !oldstate.isLoadingMore;

  @override
  bool canLoadMoreUp(ListState oldstate) => false;

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

  @override
  List<T> mergeUp(List<List<T>> results) => results[0];

  @override
  List<T> mergeDown(List<List<T>> results) => results[0];
}
