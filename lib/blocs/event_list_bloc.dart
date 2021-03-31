import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/models/event.dart';

class EventListEvent extends Equatable {
  final bool isLoad;
  final bool isMore;

  /// The search query to use.
  ///
  /// We search instead of 'get' if this is not null.
  /// Especially, `''` shows past events, whereas `null` does not.
  final String? query;

  const EventListEvent.load({this.query})
      : isLoad = true,
        isMore = false;

  const EventListEvent.more({this.query})
      : isLoad = false,
        isMore = true;

  bool get isSearch => query != null;

  @override
  List<Object?> get props => [isLoad, isMore, query];
}

class EventListState extends Equatable {
  /// The [Event]s to be shown. These are outdated if `isLoading` is true.
  final List<Event> events;

  /// A message describing why there are no results.
  final String? message;

  /// Different results are being loaded. The `events` are outdated.
  final bool isLoading;

  /// The last results have been loaded. False if there are more pages left.
  final bool isDone;

  bool get hasException => message != null;

  const EventListState.loading({required this.events})
      : message = null,
        isLoading = true,
        isDone = true;

  const EventListState.results({required this.events, required this.isDone})
      : message = null,
        isLoading = false;

  const EventListState.failure(String message)
      : events = const [],
        message = message,
        isLoading = false,
        isDone = true;

  @override
  List<Object?> get props => [events, message, isLoading, isDone];
}

// TODO: wrap list in an EventListState with isLoading and message?
/// Bloc that serves a list of [Event]. The state is `null` when loading.
class EventListBloc extends Bloc<EventListEvent, EventListState> {
  final ApiRepository api;

  EventListBloc(this.api) : super(EventListState.loading(events: []));

  @override
  Stream<EventListState> mapEventToState(EventListEvent event) async* {
    if (event.isLoad) {
      yield* _load(event.query);
    } else if (event.isMore) {
      yield* _more(event.query);
    }
  }

  Stream<EventListState> _load(String? query) async* {
    yield EventListState.loading(events: state.events);

    try {
      var listResponse = await api.getEvents(
        query: query,
        limit: 50,
        offset: 0,
      );
      if (listResponse.results.isNotEmpty) {
        yield EventListState.results(
          events: listResponse.results,
          isDone: listResponse.results.length == listResponse.count,
        );
      } else {
        // TODO: give appropriate error message for search
        yield EventListState.failure('There are no events.');
      }
    } on ApiException catch (_) {
      // TODO: give appropriate error message
      yield EventListState.failure('An error occured.');
    }
  }

  Stream<EventListState> _more(String? query) async* {
    try {
      var listResponse = await api.getEvents(
        query: query,
        limit: 50,
        offset: state.events.length,
      );
      // TODO: does this trigger a rebuild? the list doesn't change so might need to do .toList();
      state.events.addAll(listResponse.results);
      yield EventListState.results(
        events: state.events,
        isDone: listResponse.results.length == listResponse.count,
      );
    } on ApiException catch (_) {
      // TODO: give appropriate error message
      yield EventListState.failure('An error occured.');
    }
  }
}

// TODO: we may need to include the offset in the events. Otherwise it might happen that when an outdated state is added, the old state's offset is used. We may be able to solve such things by debouncing.
