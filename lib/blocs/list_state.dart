import 'package:equatable/equatable.dart';

/// Generic class to be used as state for paginated lists.
class ListState<T> extends Equatable {
  /// The results to be shown. These are outdated if `isLoading` is true.
  final List<T> results;

  /// A message describing why there are no results.
  final String? message;

  /// Different results are being loaded. The results are outdated.
  final bool isLoading;

  /// The last results have been loaded. There are no more pages left.
  final bool isDone;

  final int? count;

  bool get hasException => message != null;

  const ListState({
    required this.results,
    required this.message,
    required this.isLoading,
    required this.isLoadingMore,
    required this.isDone,
    required this.count,
  });

  ListState<T> copyWith({
    List<T>? results,
    String? message,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isDone,
    int? count,
  }) =>
      ListState<T>(
        results: results ?? this.results,
        message: message ?? this.message,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        isDone: isDone ?? this.isDone,
        count: count ?? this.count,
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

  const ListState.loading({this.count, required this.results})
      : message = null,
        isLoading = true,
        isLoadingMore = false,
        isDone = true;

  const ListState.loadingMore({this.count, required this.results})
      : message = null,
        isLoading = false,
        isLoadingMore = true,
        isDone = true;

  const ListState.success(
      {required this.results, required this.isDone, this.count})
      : message = null,
        isLoading = false,
        isLoadingMore = false;

  const ListState.failure({required String this.message})
      : results = const [],
        isLoading = false,
        isLoadingMore = false,
        isDone = true,
        count = 0;
}

class DoubleListState<T> extends Equatable {
  /// The results to be shown in the up directoin. These are outdated if
  /// `isLoading` is true.
  final List<T> resultsUp;

  /// The results to be shown in the up directoin. These are outdated if
  /// `isLoading` is true.
  final List<T> resultsDown;

  /// A message describing why there are no results.
  final String? message;

  /// Different results are being loaded. The results are outdated.
  final bool isLoading;

  /// More of the same results are being loaded in the up direction. The results
  /// are not outdated.
  final bool isLoadingMoreUp;

  /// More of the same results are being loaded in the down direction. The results
  /// are not outdated.
  final bool isLoadingMoreDown;

  /// The last results have been loaded in the up direction. There are no more
  /// pages left.
  final bool isDoneUp;

  /// The last results have been loaded in the down direction. There are no more
  /// pages left.
  final bool isDoneDown;

  bool get hasException => message != null;

  const DoubleListState({
    required this.resultsUp,
    required this.resultsDown,
    required this.message,
    required this.isLoading,
    required this.isLoadingMoreUp,
    required this.isLoadingMoreDown,
    required this.isDoneUp,
    required this.isDoneDown,
  });

  DoubleListState<T> copyWith({
    List<T>? resultsUp,
    List<T>? resultsDown,
    String? message,
    bool? isLoading,
    bool? isLoadingMoreUp,
    bool? isLoadingMoreDown,
    bool? isDoneUp,
    bool? isDoneDown,
  }) =>
      DoubleListState<T>(
        resultsUp: resultsUp ?? this.resultsUp,
        resultsDown: resultsDown ?? this.resultsDown,
        message: message ?? this.message,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMoreUp: isLoadingMoreUp ?? this.isLoadingMoreUp,
        isLoadingMoreDown: isLoadingMoreDown ?? this.isLoadingMoreDown,
        isDoneUp: isDoneUp ?? this.isDoneUp,
        isDoneDown: isDoneDown ?? this.isDoneDown,
      );

  @override
  List<Object?> get props => [
        resultsUp,
        resultsDown,
        message,
        isLoading,
        isLoadingMoreUp,
        isLoadingMoreDown,
        isDoneUp,
        isDoneDown,
      ];

  @override
  String toString() {
    return 'DoubleListState<$T>(isLoading: $isLoading, isLoadingMoreDown: $isLoadingMoreDown,'
        ' isLoadingMoreUp: $isLoadingMoreUp, isDoneUp: $isDoneUp, isDoneDown: $isDoneDown,'
        ' message: $message, ${resultsUp.length}+${resultsDown.length} ${T}s)';
  }

  const DoubleListState.loading()
      : resultsUp = const [],
        resultsDown = const [],
        message = null,
        isLoading = true,
        isLoadingMoreUp = false,
        isLoadingMoreDown = false,
        isDoneUp = false,
        isDoneDown = false;

  const DoubleListState.success({
    this.resultsUp = const [],
    this.resultsDown = const [],
    required this.isDoneUp,
    required this.isDoneDown,
  })  : message = null,
        isLoading = true,
        isLoadingMoreUp = false,
        isLoadingMoreDown = false;

  const DoubleListState.failure({required String this.message})
      : resultsUp = const [],
        resultsDown = const [],
        isLoading = false,
        isLoadingMoreUp = false,
        isLoadingMoreDown = false,
        isDoneUp = true,
        isDoneDown = true;

  DoubleListState<T> copyLoadingMoreUp() => copyWith(
      isLoading: false, isLoadingMoreDown: false, isLoadingMoreUp: true);

  DoubleListState<T> copyLoadingMoreDown() => copyWith(
      isLoading: false, isLoadingMoreDown: true, isLoadingMoreUp: false);

  DoubleListState<T> copySuccessUp(List<T> results, bool isDone) =>
      copyWith(isLoading: false, resultsUp: results, isDoneUp: isDone);

  DoubleListState<T> copySuccessDown(List<T> results, bool isDone) =>
      copyWith(isLoading: false, resultsDown: results, isDoneDown: isDone);
}
