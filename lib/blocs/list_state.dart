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

  /// More of the same results are being loaded. The results are not outdated.
  final bool isLoadingMoreUp;

  /// The last results have been loaded. There are no more pages left.
  final bool isDone;

  final bool isDoneUp;

  final int? count;

  bool get hasException => message != null;

  const ListState({
    required this.results,
    required this.message,
    required this.isLoading,
    required this.isLoadingMore,
    required this.isLoadingMoreUp,
    required this.isDone,
    required this.isDoneUp,
    required this.count,
  });

  ListState<T> copyWith({
    List<T>? results,
    String? message,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isLoadingMoreUp,
    bool? isDone,
    bool? isDoneUp,
    int? count,
  }) =>
      ListState<T>(
        results: results ?? this.results,
        message: message ?? this.message,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        isLoadingMoreUp: isLoadingMoreUp ?? this.isLoadingMoreUp,
        isDone: isDone ?? this.isDone,
        isDoneUp: isDoneUp ?? this.isDoneUp,
        count: count ?? this.count,
      );

  @override
  List<Object?> get props => [
        results,
        message,
        isLoading,
        isLoadingMore,
        isLoadingMoreUp,
        isDone,
      ];

  @override
  String toString() {
    return 'ListState<$T>(isLoading: $isLoading, isLoadingMore: $isLoadingMore,'
        ' isLoadingMoreUp: $isLoadingMore, isDone: $isDone, message: $message,'
        ' ${results.length} ${T}s)';
  }

  const ListState.loading({required this.results})
      : message = null,
        isLoading = true,
        isLoadingMore = false,
        isLoadingMoreUp = false,
        isDone = true,
        isDoneUp = true,
        count = 0;

  const ListState.loadingMoreUp({this.count, required this.results})
      : message = null,
        isLoading = false,
        isLoadingMore = false,
        isLoadingMoreUp = true,
        isDone = true,
        isDoneUp = true;

  const ListState.loadingMore({this.count, required this.results})
      : message = null,
        isLoading = false,
        isLoadingMore = true,
        isLoadingMoreUp = false,
        isDone = true,
        isDoneUp = true;

  const ListState.success(
      {required this.results,
      required this.isDone,
      required this.isDoneUp,
      this.count})
      : message = null,
        isLoading = false,
        isLoadingMore = false,
        isLoadingMoreUp = false;

  const ListState.failure({required String this.message})
      : results = const [],
        isLoading = false,
        isLoadingMore = false,
        isLoadingMoreUp = false,
        isDone = true,
        isDoneUp = true,
        count = 0;
}

class DoubleListState<T> extends Equatable {
  /// The results to be shown. These are outdated if `isLoading` is true.
  final List<T> resultsUp;
  final List<T> resultsDown;

  /// A message describing why there are no results.
  final String? message;

  /// Different results are being loaded. The results are outdated.
  final bool isLoading;

  /// More of the same results are being loaded. The results are not outdated.
  final bool isLoadingMore;

  /// More of the same results are being loaded. The results are not outdated.
  final bool isLoadingMoreUp;

  /// The last results have been loaded. There are no more pages left.
  final bool isDone;

  final bool isDoneUp;

  bool get hasException => message != null;

  const DoubleListState({
    required this.resultsUp,
    required this.resultsDown,
    required this.message,
    required this.isLoading,
    required this.isLoadingMore,
    required this.isLoadingMoreUp,
    required this.isDone,
    required this.isDoneUp,
  });

  DoubleListState<T> copyWith({
    List<T>? resultsUp,
    List<T>? resultsDown,
    String? message,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isLoadingMoreUp,
    bool? isDone,
    bool? isDoneUp,
  }) =>
      DoubleListState<T>(
        resultsUp: resultsUp ?? this.resultsUp,
        resultsDown: resultsDown ?? this.resultsDown,
        message: message ?? this.message,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        isLoadingMoreUp: isLoadingMoreUp ?? this.isLoadingMoreUp,
        isDone: isDone ?? this.isDone,
        isDoneUp: isDoneUp ?? this.isDoneUp,
      );

  @override
  List<Object?> get props => [
        resultsUp,
        resultsDown,
        message,
        isLoading,
        isLoadingMore,
        isLoadingMoreUp,
        isDone,
      ];

  @override
  String toString() {
    return 'DoubleListState<$T>(isLoading: $isLoading, isLoadingMore: $isLoadingMore,'
        ' isLoadingMoreUp: $isLoadingMore, isDone: $isDone, message: $message,'
        ' ${resultsUp.length}+${resultsDown.length} ${T}s)';
  }

  const DoubleListState.loading()
      : resultsUp = const [],
        resultsDown = const [],
        message = null,
        isLoading = true,
        isLoadingMore = false,
        isLoadingMoreUp = false,
        isDone = false,
        isDoneUp = false;

  const DoubleListState.success({
    this.resultsUp = const [],
    required this.isDoneUp,
    this.resultsDown = const [],
    required this.isDone,
  })  : message = null,
        isLoading = true,
        isLoadingMore = false,
        isLoadingMoreUp = false;

  DoubleListState<T> copyLoadingMoreUp() =>
      copyWith(isLoading: false, isLoadingMore: false, isLoadingMoreUp: true);

  DoubleListState<T> copyLoadingMoreDown() =>
      copyWith(isLoading: false, isLoadingMore: true, isLoadingMoreUp: false);

  DoubleListState<T> copySuccessUp(List<T> results, bool isDone) =>
      copyWith(isLoading: false, resultsUp: results, isDoneUp: isDone);

  DoubleListState<T> copySuccessDown(List<T> results, bool isDone) =>
      copyWith(isLoading: false, resultsDown: results, isDone: isDone);

  const DoubleListState.failure({required String this.message})
      : resultsUp = const [],
        resultsDown = const [],
        isLoading = false,
        isLoadingMore = false,
        isLoadingMoreUp = false,
        isDone = true,
        isDoneUp = true;
}
