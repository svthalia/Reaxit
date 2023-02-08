import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/models/group.dart';
import 'package:reaxit/config.dart' as config;

import 'detail_state.dart';

typedef GroupsState = DetailState<List<ListGroup>>;

class GroupsCubit extends Cubit<GroupsState> {
  final ApiRepository api;
  final MemberGroupType? groupType;

  GroupsCubit(this.api, this.groupType) : super(const LoadingState());

  Future<void> load() async {
    emit(LoadingState.from(state));
    try {
      final listResponse = await api.getGroups(limit: 1000, type: groupType);
      if (listResponse.results.isNotEmpty) {
        emit(ResultState(listResponse.results));
      } else {
        emit(const ErrorState('There are no groups.'));
      }
    } on ApiException catch (exception) {
      emit(ErrorState(_failureMessage(exception)));
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

class BoardsCubit extends GroupsCubit {
  BoardsCubit(ApiRepository api) : super(api, MemberGroupType.board);
}

class CommitteesCubit extends GroupsCubit {
  CommitteesCubit(ApiRepository api) : super(api, MemberGroupType.committee);
}

class SocietiesCubit extends GroupsCubit {
  SocietiesCubit(ApiRepository api) : super(api, MemberGroupType.society);
}

class AllGroupsCubit extends GroupsCubit {
  /// The last used search query. Can be set through `this.search(query)`.
  String? _searchQuery;

  /// A timer used to debounce calls to `this.load()` from `this.search()`.
  Timer? _searchDebounceTimer;

  AllGroupsCubit(ApiRepository api) : super(api, null);

  @override
  Future<void> load() async {
    // print("AAA");
    emit(const LoadingState());
    try {
      final query = _searchQuery;

      if (query != _searchQuery) return;

      final listResponse =
          await api.getGroups(limit: 1000, type: groupType, search: query);

      if (listResponse.results.isNotEmpty) {
        emit(ResultState(
            listResponse.results)); //listResponse.results as GroupsState);
      } else {
        if (query?.isEmpty ?? true) {
          emit(const ErrorState('There are no results.'));
        }
        emit(ErrorState('There are no results for "$query".'));
      }
    } on ApiException catch (exception) {
      emit(ErrorState(_failureMessage(exception)));
    }
  }

  void search(String? query) {
    if (query != _searchQuery) {
      _searchQuery = query;
      _searchDebounceTimer?.cancel();
      if (query?.isEmpty ?? false) {
        /// Don't get results when the query is empty.
        emit(const LoadingState());
      } else {
        _searchDebounceTimer = Timer(config.searchDebounceTime, load);
      }
    }
  }
}
