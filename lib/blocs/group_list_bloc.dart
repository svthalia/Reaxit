import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/list_event.dart';
import 'package:reaxit/blocs/list_state.dart';
import 'package:reaxit/models/group.dart';

class GroupListEvent extends ListEvent {
  final String? search;

  GroupListEvent.load({this.search}) : super.load();
  GroupListEvent.more()
      : search = null,
        super.more();

  @override
  List<Object?> get props => [isLoad, isMore, search];
}

// TODO: when dart 2.13 becomes the standard, replace this entire class by a typedef. Currently typedefs can only be used on function signatures.
class GroupListState extends ListState<GroupListEvent, ListGroup> {
  @protected
  GroupListState({
    required List<ListGroup> results,
    required String? message,
    required bool isLoading,
    required bool isLoadingMore,
    required bool isDone,
    required GroupListEvent event,
  }) : super(
          results: results,
          message: message,
          isLoading: isLoading,
          isLoadingMore: isLoadingMore,
          isDone: isDone,
          event: event,
        );

  @override
  GroupListState copyWith({
    List<ListGroup>? results,
    String? message,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isDone,
    GroupListEvent? event,
  }) =>
      GroupListState(
        results: results ?? this.results,
        message: message ?? this.message,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        isDone: isDone ?? this.isDone,
        event: event ?? this.event,
      );

  GroupListState.failure({
    required String message,
    required GroupListEvent event,
  }) : super.failure(message: message, event: event);

  GroupListState.loading({
    required List<ListGroup> results,
    required GroupListEvent event,
  }) : super.loading(results: results, event: event);

  GroupListState.loadingMore({
    required List<ListGroup> results,
    required GroupListEvent event,
  }) : super.loadingMore(results: results, event: event);

  GroupListState.success({
    required List<ListGroup> results,
    required GroupListEvent event,
    required bool isDone,
  }) : super.success(results: results, event: event, isDone: isDone);
}

class GroupListBloc extends Bloc<GroupListEvent, GroupListState> {
  static final int _firstPageSize = 9;
  static final int _pageSize = 30;

  final ApiRepository api;

  GroupListBloc(this.api)
      : super(GroupListState.loading(
          results: [],
          event: GroupListEvent.load(),
        ));

  @override
  Stream<GroupListState> mapEventToState(GroupListEvent event) async* {
    if (event.isLoad) {
      yield* _load(event);
    } else if (event.isMore && !state.isDone) {
      yield* _more(event);
    }
  }

  Stream<GroupListState> _load(GroupListEvent event) async* {
    yield state.copyWith(isLoading: true, event: event);
    // await Future.delayed(Duration(seconds: 1));

    try {
      var listResponse = await api.getGroups(
        search: event.search,
        limit: _firstPageSize,
        offset: 0,
      );
      if (listResponse.results.isNotEmpty) {
        yield GroupListState.success(
          results: listResponse.results,
          isDone: listResponse.results.length == listResponse.count,
          event: event,
        );
      } else {
        yield GroupListState.failure(
          message: state.event.search == null
              ? 'There are no groups.'
              : 'There are no groups found for "${state.event.search}"',
          event: event,
        );
      }
    } on ApiException catch (exception) {
      yield GroupListState.failure(
        message: _failureMessage(exception),
        event: event,
      );
    }
  }

  Stream<GroupListState> _more(GroupListEvent event) async* {
    yield state.copyWith(isLoadingMore: true);
    // await Future.delayed(Duration(seconds: 1));

    try {
      var listResponse = await api.getGroups(
        search: state.event.search,
        limit: _pageSize,
        offset: state.results.length,
      );
      final albums = state.results + listResponse.results;
      yield GroupListState.success(
        results: albums,
        isDone: albums.length == listResponse.count,
        event: state.event,
      );
    } on ApiException catch (exception) {
      yield GroupListState.failure(
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
