import 'package:equatable/equatable.dart';

/// Generic class to be used as state for paginated lists.
class ListState<T> extends Equatable {
  /// The results to be shown. These are outdated if `isLoading` is true.
  final List<T> results;

  /// A message describing why there are no results.
  final String? message;

  /// Different results are being loaded. The results are outdated.
  final bool isLoading;

  /// More of the same results are being loaded. The results are not outdated.
  final bool isLoadingMore;

  /// The last results have been loaded. There are no more pages left.
  final bool isDone;

  bool get hasException => message != null;

  const ListState({
    required this.results,
    required this.message,
    required this.isLoading,
    required this.isLoadingMore,
    required this.isDone,
  });

  ListState<T> copyWith({
    List<T>? results,
    String? message,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isDone,
  }) =>
      ListState<T>(
        results: results ?? this.results,
        message: message ?? this.message,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        isDone: isDone ?? this.isDone,
      );

  @override
  List<Object?> get props => [
        results,
        message,
        isLoading,
        isLoadingMore,
        isDone,
      ];

  @override
  String toString() {
    return 'ListState<$T>(isLoading: $isLoading, isLoadingMore: $isLoadingMore,'
        ' isDone: $isDone, message: $message, ${results.length} ${T}s)';
  }

  const ListState.loading({required this.results})
      : message = null,
        isLoading = true,
        isLoadingMore = false,
        isDone = true;

  const ListState.loadingMore({required this.results})
      : message = null,
        isLoading = false,
        isLoadingMore = true,
        isDone = true;

  const ListState.success({required this.results, required this.isDone})
      : message = null,
        isLoading = false,
        isLoadingMore = false;

  const ListState.failure({required String this.message})
      : results = const [],
        isLoading = false,
        isLoadingMore = false,
        isDone = true;
}

/// Generic type for states with a paginated list of results.
///
/// There are a number of subtypes:
/// * [ErrorListState] - indicates that there was an error.
/// * [LoadingListState] - indicates that we are loading.
/// * [ResultsListState] - indicates that there are results.
///   * [DoneListState] - indicates that there are no more results.
///   * [LoadingMoreListState] - indicates that we are loading more results.
abstract class XListState<T> extends Equatable {
  const XListState();

  /// A convenience method to get the results if they are available.
  ///
  /// Returns `[]` if this state is not a (subtype of) [ResultsListState].
  List<T> get results =>
      this is ResultsListState ? (this as ResultsListState<T>).results : [];

  /// A convenience method to get the error message if there is one.
  ///
  /// Returns `null` iff this state is not a (subtype of) [ErrorListState].
  String? get message =>
      this is ErrorListState ? (this as ErrorListState<T>).message : null;

  @override
  List<Object?> get props => [];
}

class LoadingListState<T> extends XListState<T> {
  const LoadingListState();
}

class ErrorListState<T> extends XListState<T> {
  @override
  final String message;

  const ErrorListState(this.message);

  @override
  List<Object?> get props => [message];
}

class ResultsListState<T> extends XListState<T> {
  @override
  final List<T> results;

  const ResultsListState(this.results);

  factory ResultsListState.withDone(List<T> results, bool isDone) =>
      isDone ? DoneListState(results) : ResultsListState(results);

  @override
  List<Object?> get props => [results];
}

class LoadingMoreListState<T> extends ResultsListState<T> {
  const LoadingMoreListState(super.results);

  factory LoadingMoreListState.from(ResultsListState<T> state) =>
      LoadingMoreListState(state.results);
}

class DoneListState<T> extends ResultsListState<T> {
  const DoneListState(super.results);
}
