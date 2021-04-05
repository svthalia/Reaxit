import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/list_event.dart';
import 'package:reaxit/blocs/list_state.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/models/member.dart';

class EventListEvent extends ListEvent {
  final String? search;

  EventListEvent.load({this.search}) : super.load();
  EventListEvent.more()
      : search = null,
        super.more();

  @override
  List<Object?> get props => [isLoad, isMore, search];
}

// TODO: when dart 2.13 becomes the standard, replace this entire class by a typedef. Currently typedefs can only be used on function signatures.
class EventListState extends ListState<EventListEvent, Event> {
  EventListState({
    required List<Event> results,
    required String? message,
    required bool isLoading,
    required bool isLoadingMore,
    required bool isDone,
    required EventListEvent event,
  }) : super(
          results: results,
          message: message,
          isLoading: isLoading,
          isLoadingMore: isLoadingMore,
          isDone: isDone,
          event: event,
        );

  @override
  EventListState copyWith({
    List<Event>? results,
    String? message,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isDone,
    EventListEvent? event,
  }) =>
      EventListState(
        results: results ?? this.results,
        message: message ?? this.message,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        isDone: isDone ?? this.isDone,
        event: event ?? this.event,
      );
  EventListState.failure({
    required String message,
    required EventListEvent event,
  }) : super.failure(message: message, event: event);

  EventListState.loading({
    required List<Event> results,
    required EventListEvent event,
  }) : super.loading(results: results, event: event);

  EventListState.loadingMore({
    required List<Event> results,
    required EventListEvent event,
  }) : super.loadingMore(results: results, event: event);

  EventListState.success({
    required List<Event> results,
    required EventListEvent event,
    required bool isDone,
  }) : super.success(results: results, event: event, isDone: isDone);
}

class EventListBloc extends Bloc<EventListEvent, EventListState> {
  static final int _firstPageSize = 9;
  static final int _pageSize = 30;

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
    // await Future.delayed(Duration(seconds: 1));

    try {
      var listResponse = await api.getEvents(
        search: event.search,
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
    } on ApiException catch (_) {
      // TODO: give appropriate error message
      yield EventListState.failure(
        message: 'An error occured.',
        event: event,
      );
    }
  }

  Stream<EventListState> _more(EventListEvent event) async* {
    yield state.copyWith(isLoadingMore: true);
    // await Future.delayed(Duration(seconds: 1));

    try {
      var listResponse = await api.getEvents(
        search: state.event.search,
        limit: _pageSize,
        offset: state.results.length,
      );
      final members = state.results + listResponse.results;
      yield EventListState.success(
        results: members,
        isDone: members.length == listResponse.count,
        event: state.event,
      );
    } on ApiException catch (_) {
      // TODO: give appropriate error message
      yield EventListState.failure(
        message: 'An error occured.',
        event: state.event,
      );
    }
  }
}
