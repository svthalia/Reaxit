import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/models/member.dart';

class MemberListEvent extends Equatable {
  final bool isLoad;
  final bool isMore;

  /// The search query to use.
  final String? search;

  const MemberListEvent.load({this.search})
      : isLoad = true,
        isMore = false;

  const MemberListEvent.more({this.search})
      : isLoad = false,
        isMore = true;

  bool get isSearch => search != null;

  @override
  List<Object?> get props => [isLoad, isMore, search];
}

class MemberListState extends Equatable {
  /// The [Event]s to be shown. These are outdated if `isLoading` is true.
  final List<ListMember> members;

  /// A message describing why there are no results.
  final String? message;

  /// Different results are being loaded. The `events` are outdated.
  final bool isLoading;

  /// More of the same results are being loaded. The `events` are not outdated.
  final bool isLoadingMore;

  /// The last results have been loaded. False if there are more pages left.
  final bool isDone;

  bool get hasException => message != null;

  const MemberListState(
      {required this.members,
      required this.message,
      required this.isLoading,
      required this.isLoadingMore,
      required this.isDone});

  const MemberListState.loading({required this.members})
      : message = null,
        isLoading = true,
        isLoadingMore = false,
        isDone = true;

  const MemberListState.loadingMore({required this.members})
      : message = null,
        isLoading = false,
        isLoadingMore = true,
        isDone = true;

  const MemberListState.results({required this.members, required this.isDone})
      : message = null,
        isLoading = false,
        isLoadingMore = false;

  const MemberListState.failure(String message)
      : members = const [],
        message = message,
        isLoading = false,
        isLoadingMore = false,
        isDone = true;

  MemberListState copyWith(
          {List<ListMember>? members,
          String? message,
          bool? isLoading,
          bool? isLoadingMore,
          bool? isDone}) =>
      MemberListState(
        members: members ?? this.members,
        message: message ?? this.message,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        isDone: isDone ?? this.isDone,
      );

  @override
  List<Object?> get props => [
        members,
        message,
        isLoading,
        isLoadingMore,
        isDone,
      ];

  @override
  String toString() {
    return 'MemberListState(isLoading: $isLoading, isLoadingMore: $isLoadingMore, isDone: $isDone, message: $message, ${members.length} members)';
  }
}

/// Bloc that serves a list of [Event]. The state is `null` when loading.
class MemberListBloc extends Bloc<MemberListEvent, MemberListState> {
  final ApiRepository api;

  MemberListBloc(this.api) : super(MemberListState.loading(members: []));

  @override
  Stream<MemberListState> mapEventToState(MemberListEvent event) async* {
    if (event.isLoad) {
      yield* _load(event.search);
    } else if (event.isMore && !state.isDone) {
      yield* _more(event.search);
    }
  }

  Stream<MemberListState> _load(String? search) async* {
    yield state.copyWith(isLoading: true);
    // await Future.delayed(Duration(seconds: 1));

    try {
      var listResponse = await api.getMembers(
        search: search,
        limit: 9,
        offset: 0,
      );
      if (listResponse.results.isNotEmpty) {
        yield MemberListState.results(
          members: listResponse.results,
          isDone: listResponse.results.length == listResponse.count,
        );
      } else {
        // TODO: give appropriate error message for search
        yield MemberListState.failure('There are no events.');
      }
    } on ApiException catch (_) {
      // TODO: give appropriate error message
      yield MemberListState.failure('An error occured.');
    }
  }

  Stream<MemberListState> _more(String? search) async* {
    yield state.copyWith(isLoadingMore: true);
    // await Future.delayed(Duration(seconds: 1));

    try {
      var listResponse = await api.getMembers(
        search: search,
        limit: 9,
        offset: state.members.length,
      );
      final members = state.members + listResponse.results;
      yield MemberListState.results(
        members: members,
        isDone: members.length == listResponse.count,
      );
    } on ApiException catch (_) {
      // TODO: give appropriate error message
      yield MemberListState.failure('An error occured.');
    }
  }
}

// TODO: We need to prevent the handling of old events overwriting that of new events. One way to do so may be to check whether the state has changed during handling, and not send a new state if some other (so newer) event has changed it already.
// TODO: We also need to keep track of search/filter/ordering parameters somehow. One way might be to include the initial event in all following states. We can then retrieve it from this.state.event in _more().
