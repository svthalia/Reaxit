import 'package:equatable/equatable.dart';

//TODO should this be split into two, one for up/down and one for just down
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

  const ListState.loadingMore({this.count, required this.results})
      : message = null,
        isLoading = false,
        isLoadingMore = true,
        isLoadingMoreUp = true,
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
