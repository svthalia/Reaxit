import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/config.dart';

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
        List<ListGroup> results = listResponse.results;

        if (results.first.type == MemberGroupType.board) {
          results = results.reversed.toList();
        }

        emit(ResultState(results));
      } else {
        emit(const ErrorState('There are no groups.'));
      }
    } on ApiException catch (exception) {
      emit(ErrorState(exception.message));
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

  // We pass null as MemberGroupType, so we get all groups.
  AllGroupsCubit(ApiRepository api) : super(api, null);

  @override
  Future<void> load() async {
    emit(const LoadingState());

    try {
      final query = _searchQuery;

      final listResponse =
          await api.getGroups(limit: 1000, type: groupType, search: query);

      // Don't load if the query changed in the meantime
      if (query != _searchQuery) return;

      if (listResponse.results.isNotEmpty) {
        emit(ResultState(listResponse.results));
      } else {
        if (query?.isEmpty ?? true) {
          emit(const ErrorState('There are no results.'));
        }
        emit(ErrorState('There are no results for "$query".'));
      }
    } on ApiException catch (exception) {
      emit(ErrorState(exception.message));
    }
  }

  void search(String? query) {
    if (query != _searchQuery) {
      _searchQuery = query;
      _searchDebounceTimer?.cancel();
      if (query?.isEmpty ?? false) {
        // Don't get results when the query is empty.
        emit(const LoadingState());
      } else {
        _searchDebounceTimer = Timer(Config.searchDebounceTime, load);
      }
    }
  }
}
