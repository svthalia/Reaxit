import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/config.dart' as config;
import 'package:reaxit/models.dart';

/// Wrapper around a [BaseEvent] to be shown in the calendar.
/// This allows to split an event into multiple parts, to show on every day in an event
class CalendarEvent {
  static final _timeFormatter = DateFormat('HH:mm');

  final BaseEvent parentEvent;
  final DateTime start;
  final DateTime end;
  final String label;
  final int part;
  final int totalParts;

  String get title => totalParts == 1
      ? parentEvent.title
      : '${parentEvent.title} day $part/$totalParts';

  int get pk => parentEvent.pk;
  String get location => parentEvent.location;

  const CalendarEvent._({
    required this.parentEvent,
    required this.start,
    required this.end,
    required this.label,
    required this.part,
    required this.totalParts,
  });

  static List<CalendarEvent> splitEventIntoCalendarEvents(BaseEvent event) {
    final localStart = event.start.toLocal();
    late final DateTime localEnd;

    // Prevent having a card for 'Until 00:00' when an event ends at midnight.
    if (event.end.toLocal().hour == 0 && event.end.toLocal().minute == 0) {
      localEnd = event.end.toLocal().subtract(const Duration(minutes: 1));
    } else {
      localEnd = event.end.toLocal();
    }

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

    final startTime = _timeFormatter.format(event.start.toLocal());
    final endTime = _timeFormatter.format(event.end.toLocal());

    if (daySpan == 1) {
      return [
        CalendarEvent._(
          parentEvent: event,
          start: event.start,
          end: event.end,
          label: '$startTime - $endTime | ${event.location}',
          part: 1,
          totalParts: 1,
        )
      ];
    } else {
      return [
        CalendarEvent._(
          parentEvent: event,
          start: event.start,
          end: _addDays(startDate, 1),
          label:
              'From $startTime | ${event.location}', //TODO: Maybe we should also use '$startTime - $endTime'?
          part: 1,
          totalParts: daySpan,
        ),
        for (var day in Iterable.generate(daySpan - 2, (i) => i + 2))
          CalendarEvent._(
            parentEvent: event,
            start: _addDays(startDate, day - 1),
            end: _addDays(startDate, day),
            label: event
                .location, //TODO: Maybe we should also use '$startTime - $endTime'?
            part: day,
            totalParts: daySpan,
          ),
        CalendarEvent._(
          parentEvent: event,
          start: endDate,
          end: event.end,
          label:
              'Until $endTime | ${event.location}', //TODO: Maybe we should also use '$startTime - $endTime'?
          part: daySpan,
          totalParts: daySpan,
        ),
      ];
    }
  }

  static DateTime _addDays(DateTime x, int days) => DateTime(
        x.year,
        x.month,
        x.day + days,
      );
}

typedef CalendarState = DoubleListState<CalendarEvent>;

class CalendarCubit extends Cubit<CalendarState> {
  static const int firstPageSize = 20;
  static const int pageSize = 5;

  final ApiRepository api;

  /// The last used search query. Can be set through `this.search(query)`.
  String? _searchQuery;

  /// The last used search query. Can be set through `this.search(query)`.
  String? get searchQuery => _searchQuery;

  /// A timer used to debounce calls to `this.load()` from `this.search()`.
  Timer? _searchDebounceTimer;

  /// The offset to be used for the next paginated request.
  int _nextOffset = 0;
  int _nextPastOffset = 0;

  /// The time rounded down to the month used to split the events in "past" and
  /// "future". Also used in the query. This is a final to avoid race conditions
  final DateTime _splitTime =
      DateTime(DateTime.now().year, DateTime.now().month);

  /// A list of events that have been removed from the previous results
  /// in order to prevent them filling up the calendar before today.
  /// These should be added in later calls to [moreUp()].
  final List<CalendarEvent> _remainingPastEvents = [];

  /// A list of events that have been removed from the previous results
  /// in order to prevent them filling up the calendar further then where
  /// the first not-loaded event will go later. These should be added in
  /// later calls to [more()].
  final List<CalendarEvent> _remainingFutureEvents = [];

  /// Debouncetimer to fix things like load
  Timer? _debounce;

  CalendarCubit(this.api) : super(const CalendarState.loading());

  Future<void> cachedLoad() async {
    if (_debounce == null || !_debounce!.isActive) {
      await load();
    }
  }

  Future<void> load() async {
    emit(const DoubleListState.loading());

    _debounce = Timer(const Duration(minutes: 10), () => {});

    try {
      final query = _searchQuery;

      // Get first page of events.
      final futureEventsResponseFuture = api.getEvents(
        start: _splitTime,
        search: query,
        ordering: 'start',
        limit: firstPageSize,
        offset: 0,
      );
      // get -1st page
      final pastEventsResponseFuture = api.getEvents(
        // TODO: we dont load partner events here?
        end: _splitTime,
        search: query,
        ordering: '-end',
        limit: pageSize,
        offset: _nextPastOffset,
      );

      // Get all partner events.
      final partnerEventsResponseFuture = api.getPartnerEvents(
        start: _splitTime,
        search: query,
        ordering: 'start',
      );
      final futureEventsResponse = await futureEventsResponseFuture;
      final pastEventsResponse = await pastEventsResponseFuture;
      final partnerEventsResponse = await partnerEventsResponseFuture;

      // Discard result if _searchQuery has
      // changed since the request was made.
      if (query != _searchQuery) return;

      final isDoneDown =
          futureEventsResponse.results.length == futureEventsResponse.count;

      _nextOffset = firstPageSize;
      _nextPastOffset = 0;

      final isDoneUp = _nextPastOffset + pastEventsResponse.results.length ==
          pastEventsResponse.count;

      // Split multi-day events.
      final futureEvents = futureEventsResponse.results
          .expand((event) => CalendarEvent.splitEventIntoCalendarEvents(event))
          .toList();

      // Split multi-day partner events.
      final partnerEvents = partnerEventsResponse.results
          .expand((event) => CalendarEvent.splitEventIntoCalendarEvents(event))
          .toList();

      // Merge the two lists.
      futureEvents.addAll(partnerEvents);
      futureEvents.sort((a, b) => a.start.compareTo(b.start));

      // If `load()`, `more()`, and `moreUp()` cause jank, the expensive operations
      // on the events could be moved to an isolate in `compute()`.

      _remainingFutureEvents.clear();

      // Remove the last partner events and day parts of events that could fill
      // up the calendar further then where the first not-loaded event will
      // go later.
      if (!isDoneDown) {
        while (futureEvents.isNotEmpty &&
            (futureEvents.last.parentEvent is PartnerEvent ||
                futureEvents.last.start !=
                    futureEvents.last.parentEvent.start)) {
          _remainingFutureEvents.add(futureEvents.removeLast());
        }
      }

      // Remove the past days of current long-running events.
      while (futureEvents.isNotEmpty &&
          futureEvents.first.start.isBefore(_splitTime)) {
        futureEvents.removeAt(0);
      }

      final pastEvents = [
        ..._remainingPastEvents..clear(),
        ...pastEventsResponse.results.expand(
          //TODO: inline this?
          (event) => CalendarEvent.splitEventIntoCalendarEvents(event),
        ),
      ].toList();

      // Sort only the new events, because the old events in
      // `_state.result` are known to be complete and sorted.
      pastEvents.sort((a, b) => a.start.compareTo(b.start));

      if (futureEventsResponse.results.isEmpty) {
        if (query?.isEmpty ?? true) {
          emit(const CalendarState.failure(message: 'There are no events.'));
        } else {
          emit(CalendarState.failure(
            message: 'There are no events found for "$query".',
          ));
        }
      } else {
        emit(CalendarState.success(
            resultsUp: pastEvents,
            resultsDown: futureEvents,
            isDoneUp: isDoneUp,
            isDoneDown: isDoneDown));
      }
    } on ApiException catch (exception) {
      emit(CalendarState.failure(message: exception.message));
    }
  }

  Future<void> more() async {
    final oldState = state;

    // Ignore calls to `more()` if there is no data, or already more coming.
    if (oldState.isDoneDown ||
        oldState.isLoading ||
        oldState.isLoadingMoreDown) {
      return;
    }

    emit(oldState.copyWith(isLoadingMoreDown: true));
    try {
      final query = _searchQuery;
      final start = _splitTime;

      // Get next page of events.
      final eventsResponse = await api.getEvents(
        // TODO: we dont load partner events here?
        start: start,
        search: query,
        ordering: 'start',
        limit: pageSize,
        offset: _nextOffset,
      );

      // Discard result if _searchQuery has
      // changed since the request was made.
      if (query != _searchQuery) return;

      final isDone =
          _nextOffset + eventsResponse.results.length == eventsResponse.count;

      _nextOffset += pageSize;

      final newEvents = [
        ..._remainingFutureEvents..clear(),
        ...eventsResponse.results.expand(
          (event) => CalendarEvent.splitEventIntoCalendarEvents(event),
        ),
      ];

      // Sort only the new events, because the old events in
      // `_state.result` are known to be complete and sorted.
      newEvents.sort((a, b) => a.start.compareTo(b.start));

      final events = [
        ...oldState.resultsDown,
        ...newEvents,
      ];

      // Remove the last partner events and day parts of events that could fill
      // up the calendar further then where the first not-loaded event will go
      // later.
      if (!isDone) {
        while (events.isNotEmpty &&
            (events.last.parentEvent is PartnerEvent ||
                events.last.start != events.last.parentEvent.start)) {
          _remainingFutureEvents.add(events.removeLast());
        }
      }

      // Remove the past days of current long-running events.
      while (events.isNotEmpty && events.first.start.isBefore(_splitTime)) {
        events.removeAt(0);
      }

      emit(oldState.copySuccessDown(events, isDone));
    } on ApiException catch (exception) {
      emit(CalendarState.failure(message: exception.message));
    }
  }

  Future<void> moreUp() async {
    final oldState = state;

    // Ignore calls to `moreUp()` if there is no data, or already more coming.
    if (oldState.isDoneUp || oldState.isLoading || oldState.isLoadingMoreUp) {
      return;
    }

    emit(oldState.copyWith(isLoadingMoreUp: true));
    try {
      final query = _searchQuery;

      // Get next page of events.
      final eventsResponse = await api.getEvents(
        // TODO: we dont load partner events here?
        end: _splitTime,
        search: query,
        ordering: '-end',
        limit: pageSize,
        offset: _nextPastOffset,
      );

      // Discard result if _searchQuery has
      // changed since the request was made.
      if (query != _searchQuery) return;

      final isDoneUp = _nextPastOffset + eventsResponse.results.length ==
          eventsResponse.count;
      _nextPastOffset += pageSize;

      final newEvents = [
        ..._remainingPastEvents..clear(),
        ...eventsResponse.results.expand(
          (event) => CalendarEvent.splitEventIntoCalendarEvents(event),
        ),
      ].toList();

      // Sort only the new events, because the old events in
      // `_state.result` are known to be complete and sorted.
      newEvents.sort((a, b) => a.start.compareTo(b.start));

      final events = [
        ...newEvents,
        ...oldState.resultsUp,
      ];

      // Remove the first partner events and day parts of events that could fill
      // up the calendar further then where the first not-loaded event will go
      // later.
      if (!isDoneUp) {
        while (events.isNotEmpty &&
            (events.first.parentEvent is PartnerEvent ||
                events.first.end != events.first.parentEvent.end)) {
          _remainingPastEvents.add(events.removeAt(0));
        }
      }

      // Remove the future days of current long-running events.
      while (events.isNotEmpty && !events.last.start.isBefore(_splitTime)) {
        events.removeLast();
      }

      emit(oldState.copySuccessUp(events, isDoneUp));
    } on ApiException catch (exception) {
      emit(CalendarState.failure(message: exception.message));
    }
  }

  /// Set this cubit's `searchQuery` and load the events for that query.
  ///
  /// Use `null` as argument to remove the search query.
  void search(String? query) {
    if (query != _searchQuery) {
      _searchQuery = query;
      _searchDebounceTimer?.cancel();
      if (query?.isEmpty ?? false) {
        /// Don't get results when the query is empty.
        emit(const CalendarState.loading());
      } else {
        _searchDebounceTimer = Timer(config.searchDebounceTime, load);
      }
    }
  }
}
