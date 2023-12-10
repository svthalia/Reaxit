import 'package:equatable/equatable.dart';

/// Generic type for states with a single result.
///
/// There are a number of subtypes:
/// * [ResultState] - indicates that there is a result.
/// * [LoadingState] - indicates that we are loading.
/// * [ErrorState] - indicates that there is an error.
///
/// Additionally there are:
/// * [LoadingResultState] - indicates that there is a result and we are loading.
///   This is a subtype of both [ResultState] and [LoadingState].
/// * [LoadingErrorState] - indicates that there is an error and we are loading.
///   This is a subtype of both [ErrorState] and [LoadingState]
///
/// Additional subtypes can be added as needed.
sealed class DetailState<T> extends Equatable {
  const DetailState();

  T? get result => this is ResultState ? (this as ResultState<T>).result : null;
  String? get message =>
      this is ErrorState ? (this as ErrorState<T>).message : null;
}

/// A generic state that indicates that there is a result.
///
/// A subtype is [LoadingResultState] which indicates that we are also loading.
class ResultState<T> extends DetailState<T> {
  @override
  final T result;

  const ResultState(this.result);

  @override
  List<Object?> get props => [result];
}

/// A generic state that indicates that there is an error.
///
/// A subtype is [LoadingErrorState] which indicates that we are also loading.
class ErrorState<T> extends DetailState<T> {
  @override
  final String message;

  const ErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

/// A generic state that indicates that we are loading.
///
/// This is also implemented by [LoadingResultState] and [LoadingErrorState],
/// which also indicate that there is a result or an error.
///
/// [LoadingState.from] can be used to convert any state into either a
/// [LoadingState] or the right subtype of it.
class LoadingState<T> extends DetailState<T> {
  const LoadingState();

  factory LoadingState.from(DetailState<T> state) {
    if (state is ResultState<T>) {
      return LoadingResultState(state.result);
    } else if (state is ErrorState<T>) {
      return LoadingErrorState(state.message);
    } else {
      return const LoadingState();
    }
  }

  @override
  List<Object?> get props => [];
}

/// A generic state that indicates that we are loading and there is a result.
class LoadingResultState<T> extends ResultState<T> implements LoadingState<T> {
  const LoadingResultState(T result) : super(result);
}

/// A generic state that indicates that we are loading and there is an error.
class LoadingErrorState<T> extends ErrorState<T> implements LoadingState<T> {
  const LoadingErrorState(String message) : super(message);
}
