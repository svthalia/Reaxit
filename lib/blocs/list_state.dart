import 'package:equatable/equatable.dart';

/// Generic type for states with a paginated list of results.
///
/// There are a number of subtypes:
/// * [ErrorListState] - indicates that there was an error.
/// * [LoadingListState] - indicates that we are loading.
/// * [ResultsListState] - indicates that there are results.
///   * [DoneListState] - indicates that there are no more results.
///   * [LoadingMoreListState] - indicates that we are loading more results.
abstract class ListState<T> extends Equatable {
  const ListState();

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

class LoadingListState<T> extends ListState<T> {
  const LoadingListState();
}

class ErrorListState<T> extends ListState<T> {
  @override
  final String message;

  const ErrorListState(this.message);

  @override
  List<Object?> get props => [message];
}

class ResultsListState<T> extends ListState<T> {
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
