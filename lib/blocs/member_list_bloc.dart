import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/list_event.dart';
import 'package:reaxit/blocs/list_state.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/models/member.dart';

class MemberListEvent extends ListEvent {
  final String? search;

  MemberListEvent.load({this.search}) : super.load();
  MemberListEvent.more()
      : search = null,
        super.more();

  @override
  List<Object?> get props => [isLoad, isMore, search];
}

// TODO: when dart 2.13 becomes the standard, replace this entire class by a typedef. Currently typedefs can only be used on function signatures.
class MemberListState extends ListState<MemberListEvent, ListMember> {
  MemberListState({
    required List<ListMember> results,
    required String? message,
    required bool isLoading,
    required bool isLoadingMore,
    required bool isDone,
    required MemberListEvent event,
  }) : super(
          results: results,
          message: message,
          isLoading: isLoading,
          isLoadingMore: isLoadingMore,
          isDone: isDone,
          event: event,
        );

  @override
  MemberListState copyWith({
    List<ListMember>? results,
    String? message,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isDone,
    MemberListEvent? event,
  }) =>
      MemberListState(
        results: results ?? this.results,
        message: message ?? this.message,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        isDone: isDone ?? this.isDone,
        event: event ?? this.event,
      );
  MemberListState.failure({
    required String message,
    required MemberListEvent event,
  }) : super.failure(message: message, event: event);

  MemberListState.loading({
    required List<ListMember> results,
    required MemberListEvent event,
  }) : super.loading(results: results, event: event);

  MemberListState.loadingMore({
    required List<ListMember> results,
    required MemberListEvent event,
  }) : super.loadingMore(results: results, event: event);

  MemberListState.success({
    required List<ListMember> results,
    required MemberListEvent event,
    required bool isDone,
  }) : super.success(results: results, event: event, isDone: isDone);
}

class MemberListBloc extends Bloc<MemberListEvent, MemberListState> {
  static final int _firstPageSize = 9;
  static final int _pageSize = 30;

  final ApiRepository api;

  MemberListBloc(this.api)
      : super(MemberListState.loading(
          results: [],
          event: MemberListEvent.load(),
        ));

  @override
  Stream<MemberListState> mapEventToState(MemberListEvent event) async* {
    if (event.isLoad) {
      yield* _load(event);
    } else if (event.isMore && !state.isDone) {
      yield* _more(event);
    }
  }

  Stream<MemberListState> _load(MemberListEvent event) async* {
    yield state.copyWith(isLoading: true, event: event);
    // await Future.delayed(Duration(seconds: 1));

    try {
      var listResponse = await api.getMembers(
        search: event.search,
        limit: _firstPageSize,
        offset: 0,
      );
      if (listResponse.results.isNotEmpty) {
        yield MemberListState.success(
          results: listResponse.results,
          isDone: listResponse.results.length == listResponse.count,
          event: event,
        );
      } else {
        yield MemberListState.failure(
          message: state.event.search == null
              ? 'There are no members.'
              : 'There are no members found for "${state.event.search}"',
          event: event,
        );
      }
    } on ApiException catch (_) {
      // TODO: give appropriate error message
      yield MemberListState.failure(
        message: 'An error occured.',
        event: event,
      );
    }
  }

  Stream<MemberListState> _more(MemberListEvent event) async* {
    yield state.copyWith(isLoadingMore: true);
    // await Future.delayed(Duration(seconds: 1));

    try {
      var listResponse = await api.getMembers(
        search: state.event.search,
        limit: _pageSize,
        offset: state.results.length,
      );
      final members = state.results + listResponse.results;
      yield MemberListState.success(
        results: members,
        isDone: members.length == listResponse.count,
        event: state.event,
      );
    } on ApiException catch (_) {
      // TODO: give appropriate error message
      yield MemberListState.failure(
        message: 'An error occured.',
        event: state.event,
      );
    }
  }
}

// TODO: We need to prevent the handling of old events overwriting that of new events. One way to do so may be to check whether the state has changed during handling, and not send a new state if some other (so newer) event has changed it already.
