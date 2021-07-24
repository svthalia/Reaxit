import 'package:equatable/equatable.dart';
import 'package:reaxit/blocs/list_event.dart';

/// Generic class to be used as state for paginated lists.
///
/// Keeps the instance of the event that contains the information used
/// to retrieve for the result, such as a search query.
class ListState<EventType extends ListEvent, ElementType> extends Equatable {
  /// The results to be shown. These are outdated if `isLoading` is true.
  final List<ElementType> results;

  /// A message describing why there are no results.
  final String? message;

  /// Different results are being loaded. The results are outdated.
  final bool isLoading;

  /// More of the same results are being loaded. The results are not outdated.
  final bool isLoadingMore;

  /// The last results have been loaded. There are no more pages left.
  final bool isDone;

  /// The event that requested the first results (containing e.g. a search query).
  ///
  /// For instance, if [ListEvent.load(search='x')] is fired, then the states
  /// following that event will contain the event. If later [MemberListEvent.more()]
  /// is added, its results will also contain the initial `load` event.
  final EventType event;

  bool get hasException => message != null;

  const ListState({
    required this.results,
    required this.message,
    required this.isLoading,
    required this.isLoadingMore,
    required this.isDone,
    required this.event,
  });

  ListState<EventType, ElementType> copyWith({
    List<ElementType>? results,
    String? message,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isDone,
    EventType? event,
  }) =>
      ListState<EventType, ElementType>(
        results: results ?? this.results,
        message: message ?? this.message,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        isDone: isDone ?? this.isDone,
        event: event ?? this.event,
      );

  @override
  List<Object?> get props => [
        results,
        message,
        isLoading,
        isLoadingMore,
        isDone,
        event,
      ];

  @override
  String toString() {
    return 'ListState<$EventType,$ElementType>(isLoading: $isLoading, '
        'isLoadingMore: $isLoadingMore, isDone: $isDone, message: $message, '
        '${results.length} ${ElementType}s, event: $event)';
  }

  const ListState.loading({required this.results, required this.event})
      : message = null,
        isLoading = true,
        isLoadingMore = false,
        isDone = true;

  const ListState.loadingMore({required this.results, required this.event})
      : message = null,
        isLoading = false,
        isLoadingMore = true,
        isDone = true;

  const ListState.success(
      {required this.results, required this.isDone, required this.event})
      : message = null,
        isLoading = false,
        isLoadingMore = false;

  const ListState.failure({required String this.message, required this.event})
      : results = const [],
        isLoading = false,
        isLoadingMore = false,
        isDone = true;
}
