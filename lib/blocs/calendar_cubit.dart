import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/blocs/list_cubit.dart';
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

  String get title =>
      totalParts == 1
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

    final endDate = DateTime(localEnd.year, localEnd.month, localEnd.day);

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
        ),
      ];
    } else {
      return [
        CalendarEvent._(
          parentEvent: event,
          start: event.start,
          end: _addDays(startDate, 1),
          label: 'From $startTime | ${event.location}',
          part: 1,
          totalParts: daySpan,
        ),
        for (var day in Iterable.generate(daySpan - 2, (i) => i + 2))
          CalendarEvent._(
            parentEvent: event,
            start: _addDays(startDate, day - 1),
            end: _addDays(startDate, day),
            label: 'All day | ${event.location}',
            part: day,
            totalParts: daySpan,
          ),
        CalendarEvent._(
          parentEvent: event,
          start: endDate,
          end: event.end,
          label: 'Until $endTime | ${event.location}',
          part: daySpan,
          totalParts: daySpan,
        ),
      ];
    }
  }

  static DateTime _addDays(DateTime x, int days) =>
      DateTime(x.year, x.month, x.day + days);

  bool get isFirstPart => part == 1;
  bool get isLasttPart => part == totalParts;
}

class CalendarState extends Equatable {
  final DateTime now;
  final DoubleListState<CalendarEvent> events;

  /// The results to be shown in the up directoin. These are outdated if
  /// `isLoading` is true.
  List<CalendarEvent> get resultsUp => events.resultsUp;

  /// The results to be shown in the up directoin. These are outdated if
  /// `isLoading` is true.
  List<CalendarEvent> get resultsDown => events.resultsDown;

  /// A message describing why there are no results.
  String? get message => events.message;

  /// Different results are being loaded. The results are outdated.
  bool get isLoading => events.isLoading;

  /// More of the same results are being loaded in the up direction. The results
  /// are not outdated.
  bool get isLoadingMoreUp => events.isLoadingMoreUp;

  /// More of the same results are being loaded in the down direction. The results
  /// are not outdated.
  bool get isLoadingMoreDown => events.isLoadingMoreDown;

  /// The last results have been loaded in the up direction. There are no more
  /// pages left.
  bool get isDoneUp => events.isDoneUp;

  /// The last results have been loaded in the down direction. There are no more
  /// pages left.
  bool get isDoneDown => events.isDoneDown;

  bool get hasException => message != null;

  const CalendarState(this.now, this.events);

  @override
  List<Object?> get props => [now, events];
}

class EventsSource extends ListCubitSource<Event, CalendarEvent> {
  CalendarCubit cubit;

  static const int firstPageSize = 20;
  static const int pageSize = 5;

  EventsSource(this.cubit);

  @override
  Future<ListResponse<Event>> getDown(int offset) => cubit.api.getEvents(
    start: cubit._splitTime,
    search: cubit.searchQuery,
    ordering: 'start',
    limit: offset == 0 ? firstPageSize : pageSize,
    offset: offset,
  );

  @override
  Future<ListResponse<Event>> getUp(int offset) => cubit.api.getEvents(
    end: cubit._splitTime,
    search: cubit.searchQuery,
    ordering: '-end',
    limit: offset == 0 ? firstPageSize : pageSize,
    offset: offset,
  );

  @override
  List<CalendarEvent> processUp(List<Event> results) =>
      results
          .expand(CalendarEvent.splitEventIntoCalendarEvents)
          .where((element) => element.start.isBefore(cubit._splitTime))
          .toList();

  @override
  List<CalendarEvent> processDown(List<Event> results) =>
      results
          .expand(CalendarEvent.splitEventIntoCalendarEvents)
          .whereNot((element) => element.start.isBefore(cubit._splitTime))
          .toList();
}

class PartnerEventSource extends ListCubitSource<PartnerEvent, CalendarEvent> {
  CalendarCubit cubit;

  static const int pageSize = 5;

  PartnerEventSource(this.cubit);

  @override
  Future<ListResponse<PartnerEvent>> getDown(int offset) =>
      cubit._remainingFutureEvents.none(
            (element) => element.parentEvent is PartnerEvent,
          )
          ? cubit.api.getPartnerEvents(
            start: cubit._splitTime,
            search: cubit.searchQuery,
            ordering: 'start',
            offset: offset,
          )
          : Future.value(const ListResponse(0, []));

  @override
  Future<ListResponse<PartnerEvent>> getUp(int offset) =>
      cubit._remainingPastEvents.none(
            (element) => element.parentEvent is PartnerEvent,
          )
          ? cubit.api.getPartnerEvents(
            start: cubit._splitTime,
            search: cubit.searchQuery,
            ordering: '-end',
            offset: offset,
          )
          : Future.value(const ListResponse(0, []));

  @override
  List<CalendarEvent> processUp(List<PartnerEvent> results) =>
      results
          .expand(CalendarEvent.splitEventIntoCalendarEvents)
          .where((element) => element.start.isBefore(cubit._splitTime))
          .toList();

  @override
  List<CalendarEvent> processDown(List<PartnerEvent> results) =>
      results
          .expand(CalendarEvent.splitEventIntoCalendarEvents)
          .whereNot((element) => element.start.isBefore(cubit._splitTime))
          .toList();
}

class CalendarCubit extends ListCubit<Event, CalendarEvent, CalendarState> {
  CalendarCubit(ApiRepository api)
    : super(
        api,
        CalendarState(DateTime.now(), const DoubleListState.loading()),
      );
  late final List<ListCubitSource<dynamic, CalendarEvent>> _sources = [
    EventsSource(this),
    PartnerEventSource(this),
  ];

  @override
  List<ListCubitSource<dynamic, CalendarEvent>> get sources => _sources;

  /// A list of events that have been removed from the previous results
  /// in order to prevent them filling up the calendar before today.
  /// These should be added in later calls to [moreUp()].
  List<CalendarEvent> _remainingPastEvents = [];

  /// A list of events that have been removed from the previous results
  /// in order to prevent them filling up the calendar further then where
  /// the first not-loaded event will go later. These should be added in
  /// later calls to [more()].
  List<CalendarEvent> _remainingFutureEvents = [];

  /// The time rounded down to the month used to split the events in "past" and
  /// "future". Also used in the query. This is a final to avoid race conditions
  DateTime get _splitTime => DateTime(_truthTime.year, _truthTime.month);

  // _truthTime is the time that we base "now" on for the calendar.
  DateTime _truthTime = DateTime.now();

  @override
  bool canLoadMoreDown(CalendarState oldstate) =>
      !oldstate.isDoneDown &&
      !oldstate.isLoading &&
      !oldstate.isLoadingMoreDown;

  @override
  bool canLoadMoreUp(CalendarState oldstate) =>
      !oldstate.isDoneUp && !oldstate.isLoading && !oldstate.isLoadingMoreUp;

  @override
  List<CalendarEvent> mergeUp(List<List<CalendarEvent>> results) {
    List<CalendarEvent> newEvents = [
      ..._remainingPastEvents,
      ...results.flattened,
    ];
    _remainingPastEvents.clear();
    newEvents.sortBy((element) => element.start);
    return newEvents;
  }

  @override
  List<CalendarEvent> mergeDown(List<List<CalendarEvent>> results) {
    List<CalendarEvent> newEvents = [
      ..._remainingFutureEvents,
      ...results.flattened,
    ];
    _remainingPastEvents.clear();
    newEvents.sortBy((e) => e.start);
    return newEvents;
  }

  @override
  List<CalendarEvent> filterUp(List<CalendarEvent> upResults) {
    // Get the first non-parter event that will be shown on the calendar.
    CalendarEvent lastIncludedEvent = upResults.firstWhere(
      (event) => event.parentEvent is! PartnerEvent && event.isLasttPart,
      orElse: () => upResults.first,
    );
    // Remove anything before
    _remainingPastEvents =
        upResults
            .where((element) => element.start.isBefore(lastIncludedEvent.start))
            .toList();
    return upResults
        .whereNot((element) => element.start.isBefore(lastIncludedEvent.start))
        .toList();
  }

  @override
  List<CalendarEvent> filterDown(List<CalendarEvent> downResults) {
    // Get the last non-parter event that will be shown on the calendar.
    CalendarEvent lastIncludedEvent = downResults.lastWhere(
      (event) => event.parentEvent is! PartnerEvent && event.isFirstPart,
      orElse: () => downResults.last,
    );
    // Remove anything before
    _remainingFutureEvents =
        downResults
            .where((element) => lastIncludedEvent.start.isBefore(element.start))
            .toList();
    return downResults
        .whereNot((element) => lastIncludedEvent.start.isBefore(element.start))
        .toList();
  }

  @override
  List<CalendarEvent> combineDown(
    List<CalendarEvent> downResults,
    CalendarState oldstate,
  ) => [...oldstate.resultsDown, ...downResults];

  @override
  List<CalendarEvent> combineUp(
    List<CalendarEvent> upResults,
    CalendarState oldstate,
  ) => [...upResults, ...oldstate.resultsUp];

  @override
  void cleanupOldState() {
    _truthTime = DateTime.now();
  }

  @override
  CalendarState empty(String? query) => switch (query) {
    null => CalendarState(
      _truthTime,
      const DoubleListState.failure(message: 'No events found.'),
    ),
    '' => CalendarState(
      _truthTime,
      const DoubleListState.failure(message: 'Start searching for events'),
    ),
    var q => CalendarState(
      _truthTime,
      DoubleListState.failure(message: 'No events found found for query "$q"'),
    ),
  };

  @override
  CalendarState failure(String message) =>
      CalendarState(_truthTime, DoubleListState.failure(message: message));

  @override
  CalendarState loading() =>
      CalendarState(_truthTime, const DoubleListState.loading());

  @override
  CalendarState loadingDown(CalendarState oldstate) => CalendarState(
    _truthTime,
    oldstate.events.copyWith(isLoadingMoreDown: true),
  );

  @override
  CalendarState loadingUp(CalendarState oldstate) => CalendarState(
    _truthTime,
    oldstate.events.copyWith(isLoadingMoreUp: true),
  );

  @override
  CalendarState newState({
    List<CalendarEvent> resultsUp = const [],
    List<CalendarEvent> resultsDown = const [],
    required bool isDoneUp,
    required bool isDoneDown,
  }) => CalendarState(
    _truthTime,
    DoubleListState.success(
      resultsUp: resultsUp,
      resultsDown: resultsDown,
      isDoneUp: isDoneUp,
      isDoneDown: isDoneDown,
    ),
  );

  @override
  List<CalendarEvent> processDown(List<Event> downResults) =>
      downResults
          .expand(CalendarEvent.splitEventIntoCalendarEvents)
          .whereNot((element) => element.start.isBefore(_splitTime))
          .toList();

  @override
  List<CalendarEvent> processUp(List<Event> upResults) =>
      upResults
          .expand(CalendarEvent.splitEventIntoCalendarEvents)
          .where((element) => element.start.isBefore(_splitTime))
          .toList();

  @override
  CalendarState updateDown(
    CalendarState oldstate,
    List<CalendarEvent> downResults,
    bool isDoneDown,
  ) => CalendarState(
    _truthTime,
    oldstate.events.copyWith(resultsDown: downResults, isDoneDown: isDoneDown),
  );

  @override
  CalendarState updateUp(
    CalendarState oldstate,
    List<CalendarEvent> upResults,
    bool isDoneUp,
  ) => CalendarState(
    _truthTime,
    oldstate.events.copyWith(resultsUp: upResults, isDoneUp: isDoneUp),
  );
}
