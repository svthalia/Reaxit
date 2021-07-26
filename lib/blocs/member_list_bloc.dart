import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api_repository.dart';
import 'package:reaxit/blocs/list_event.dart';
import 'package:reaxit/blocs/list_state.dart';
import 'package:reaxit/models/member.dart';

class MemberListEvent extends ListEvent {
  final String? search;

  const MemberListEvent.load({this.search}) : super.load();
  const MemberListEvent.more()
      : search = null,
        super.more();

  @override
  List<Object?> get props => [isLoad, isMore, search];
}

typedef MemberListState = ListState<MemberListEvent, ListMember>;

class MemberListBloc extends Bloc<MemberListEvent, MemberListState> {
  static const int _firstPageSize = 60;
  static const int _pageSize = 30;

  final ApiRepository api;

  MemberListBloc(this.api)
      : super(const MemberListState.loading(
          results: [],
          event: MemberListEvent.load(),
        ));

  // TODO: Only handle the most recent event. Don't use results from handling of old events.
  //  This may be possible using Stream.switchMap in this.transformEvents by RxDart, if we are willing to add RxDart.
  //  Otherwise we could handle it in the mapEventToState methods, of even in transformTransition (drop transitions that belong to an old event).

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
              : 'There are no members found for "${state.event.search}".',
          event: event,
        );
      }
    } on ApiException catch (exception) {
      yield MemberListState.failure(
        message: _failureMessage(exception),
        event: event,
      );
    }
  }

  Stream<MemberListState> _more(MemberListEvent event) async* {
    yield state.copyWith(isLoadingMore: true);

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
    } on ApiException catch (exception) {
      yield MemberListState.failure(
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
