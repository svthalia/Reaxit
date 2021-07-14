import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api_repository.dart';
import 'package:reaxit/blocs/list_event.dart';
import 'package:reaxit/blocs/list_state.dart';
import 'package:reaxit/models/event.dart';

class EventListEvent extends ListEvent {
  final String? search;
  final DateTime date = DateTime.now();

  EventListEvent.load({this.search}) : super.load();
  EventListEvent.more()
      : search = null,
        super.more();

  @override
  List<Object?> get props => [isLoad, isMore, search];
}

typedef EventListState = ListState<EventListEvent, Event>;

class EventListBloc extends Bloc<EventListEvent, EventListState> {
  static final int _firstPageSize = 20;
  static final int _pageSize = 10;

  final ApiRepository api;

  EventListBloc(this.api)
      : super(EventListState.loading(
          results: [],
          event: EventListEvent.load(),
        ));

  @override
  Stream<EventListState> mapEventToState(EventListEvent event) async* {
    if (event.isLoad) {
      yield* _load(event);
    } else if (event.isMore && !state.isDone) {
      yield* _more(event);
    }
  }

  Stream<EventListState> _load(EventListEvent event) async* {
    yield state.copyWith(isLoading: true, event: event);

    try {
      var listResponse = await api.getEvents(
        search: event.search,
        ordering: 'start',
        start: event.search == null ? event.date : null,
        limit: _firstPageSize,
        offset: 0,
      );
      if (listResponse.results.isNotEmpty) {
        yield EventListState.success(
          results: listResponse.results,
          isDone: listResponse.results.length == listResponse.count,
          event: event,
        );
      } else {
        yield EventListState.failure(
          message: state.event.search == null
              ? 'There are no members.'
              : 'There are no members found for "${state.event.search}"',
          event: event,
        );
      }
    } on ApiException catch (exception) {
      yield EventListState.failure(
        message: _failureMessage(exception),
        event: event,
      );
    }
  }

  Stream<EventListState> _more(EventListEvent event) async* {
    yield state.copyWith(isLoadingMore: true);

    try {
      var listResponse = await api.getEvents(
        search: state.event.search,
        ordering: 'start',
        start: state.event.search == null ? event.date : null,
        limit: _pageSize,
        offset: state.results.length,
      );
      final events = state.results + listResponse.results;
      yield EventListState.success(
        results: events,
        isDone: events.length == listResponse.count,
        event: state.event,
      );
    } on ApiException catch (exception) {
      yield EventListState.failure(
        message: _failureMessage(exception),
        event: state.event,
      );
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
}
