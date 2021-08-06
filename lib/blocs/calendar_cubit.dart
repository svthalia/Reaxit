import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api_repository.dart';
import 'package:reaxit/models/event.dart';

/// Wrapper around a [BaseEvent] to be shown in the calendar.
/// This allows to split an event into multiple parts, to show on every day in an event
class CalendarEvent {
  final BaseEvent parentEvent;
  final DateTime start;
  final DateTime end;
  final String title;

  int get pk => parentEvent.pk;
  String get location => parentEvent.location;

  CalendarEvent._({
    required this.parentEvent,
    required this.title,
    required this.start,
    required this.end,
  });

  static List<CalendarEvent> splitEventIntoCalendarEvents(BaseEvent event) {
    final localStart = event.start.toLocal();
    final localEnd = event.end.toLocal();

    final startDate = DateTime(
      localStart.year,
      localStart.month,
      localStart.day,
    );

    final endDate = DateTime(
      localEnd.year,
      localEnd.month,
      localEnd.day,
    );

    final daySpan = endDate.difference(startDate).inDays + 1;

    if (daySpan == 1) {
      return [
        CalendarEvent._(
          parentEvent: event,
          title: event.title,
          start: event.start,
          end: event.end,
        )
      ];
    } else {
      return [
        CalendarEvent._(
          parentEvent: event,
          title: event.title + ' day 1/$daySpan',
          start: event.start,
          end: startDate.add(const Duration(days: 1)),
        ),
        for (var day in Iterable.generate(daySpan - 2, (i) => i + 2))
          CalendarEvent._(
            parentEvent: event,
            title: event.title + ' day $day/$daySpan',
            start: startDate.add(Duration(days: day - 1)),
            end: startDate.add(Duration(days: day)),
          ),
        CalendarEvent._(
          parentEvent: event,
          title: event.title + ' day $daySpan/$daySpan',
          start: endDate,
          end: event.end,
        ),
      ];
    }
  }
}

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

typedef CalendarState = ListState<CalendarEvent>;

class CalendarCubit extends Cubit<CalendarState> {
  static const int firstPageSize = 20;
  static const int pageSize = 10;

  final ApiRepository api;

  /// The last used search query. Can be set through `this.search(query)`.
  String? _searchQuery;

  /// The last used search query. Can be set through `this.search(query)`.
  String? get searchQuery => _searchQuery;

  /// The time used as filter, stored so that later
  /// paginated requests have the correct offset.
  DateTime? _lastLoadTime;

  /// The offset to be used for the next paginated request.
  int _nextOffset = 0;

  /// A list of events that have been removed from the previous results
  /// in order to prevent them filling up the calendar further then where
  /// the first not-loaded event will go later. These should be added in
  /// later calls to [more()].
  final List<CalendarEvent> _remainingEvents = [];

  CalendarCubit(this.api) : super(const CalendarState.loading(results: []));

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      _lastLoadTime = DateTime.now();
      final query = _searchQuery;
      final start = query == null ? _lastLoadTime : null;

      // Get first page of events.
      final eventsResponse = await api.getEvents(
        start: start,
        search: query,
        ordering: 'start',
        limit: firstPageSize,
        offset: 0,
      );

      _nextOffset = firstPageSize;

      // Get all partner events.
      final partnerEventsResponse = await api.getPartnerEvents(
        start: start,
        search: query,
        ordering: 'start',
      );

      // Split multi-day events.
      final events = eventsResponse.results
          .expand((event) => CalendarEvent.splitEventIntoCalendarEvents(event))
          .toList();

      // Split multi-day partner events.
      final partnerEvents = partnerEventsResponse.results
          .expand((event) => CalendarEvent.splitEventIntoCalendarEvents(event))
          .toList();

      // Merge the two lists.
      events.addAll(partnerEvents);
      events.sort((a, b) => a.start.compareTo(b.start));

      _remainingEvents.clear();

      // Remove the last partner events and day parts of events that could fill
      // fill up the calendar further then where the first not-loaded event will
      // go later.
      if (eventsResponse.results.length != eventsResponse.count) {
        while (events.isNotEmpty &&
            (events.last.parentEvent is PartnerEvent ||
                events.last.start != events.last.parentEvent.start)) {
          _remainingEvents.add(events.removeLast());
        }
      }

      if (start != null) {
        // Remove the past days of current long-running events.
        while (events.isNotEmpty && events.first.end.isBefore(start)) {
          events.removeAt(0);
        }
      }

      if (eventsResponse.results.isEmpty) {
        if (query?.isEmpty ?? true) {
          emit(const CalendarState.failure(message: 'There are no events.'));
        } else {
          emit(CalendarState.failure(
            message: 'There are no events found for "$query".',
          ));
        }
      } else {
        emit(CalendarState.success(
          results: events,
          isDone: eventsResponse.results.length == eventsResponse.count,
        ));
      }
    } on ApiException catch (exception) {
      emit(CalendarState.failure(message: _failureMessage(exception)));
    }
  }

  Future<void> more() async {
    final _state = state;

    // Ignore calls to `more()` if there is no data, or already more coming.
    if (_state.isDone || _state.isLoading || _state.isLoadingMore) return;

    emit(_state.copyWith(isLoadingMore: true));
    try {
      final query = _searchQuery;
      final start = query == null ? _lastLoadTime : null;

      // Get first page of events.
      final eventsResponse = await api.getEvents(
        start: start,
        search: query,
        ordering: 'start',
        limit: pageSize,
        offset: _nextOffset,
      );

      _nextOffset += pageSize;

      final newEvents = [
        ..._remainingEvents..clear(),
        ...eventsResponse.results.expand(
          (event) => CalendarEvent.splitEventIntoCalendarEvents(event),
        ),
      ];

      // Sort only the new events, because the old events in
      // `_state.result` are known to be complete and sorted.
      newEvents.sort((a, b) => a.start.compareTo(b.start));

      final events = [
        ..._state.results,
        ...newEvents,
      ];

      // Remove the last partner events and day parts of events that could fill
      // fill up the calendar further then where the first not-loaded event will
      // go later.
      if (eventsResponse.results.length != eventsResponse.count) {
        while (events.isNotEmpty &&
            (events.last.parentEvent is PartnerEvent ||
                events.last.start != events.last.parentEvent.start)) {
          _remainingEvents.add(events.removeLast());
        }
      }

      if (start != null) {
        // Remove the past days of current long-running events.
        while (events.isNotEmpty && events.first.end.isBefore(start)) {
          events.removeAt(0);
        }
      }

      emit(CalendarState.success(
        results: events,
        isDone: eventsResponse.results.length != eventsResponse.count,
      ));
    } on ApiException catch (exception) {
      emit(CalendarState.failure(message: _failureMessage(exception)));
    }
  }

  /// Set this cubit's `searchQuery` and load the events for that query.
  ///
  /// Use `null` as argument to remove the search query.
  Future<void> search(String? query) async {
    // TODO: Debounce the call to load: e.g. wait for 100ms and then load,
    //  saving a future so that later `search` calls within the 100ms wait
    //  do not trigger an additional `load` call.
    if (query != _searchQuery) {
      _searchQuery = query;
      await load();
    }
  }

  String _failureMessage(ApiException exception) {
    switch (exception) {
      case ApiException.noInternet:
        return 'Not connected to the internet.';
      default:
        return 'An unknown error occurred.';
    }
  }

  // TODO: Explore doing the expensive operations in load() and more() in
  //  an isolate with compute().
}
