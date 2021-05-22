import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/list_event.dart';
import 'package:reaxit/blocs/list_state.dart';
import 'package:reaxit/models/album.dart';

class AlbumListEvent extends ListEvent {
  final String? search;

  AlbumListEvent.load({this.search}) : super.load();
  AlbumListEvent.more()
      : search = null,
        super.more();

  @override
  List<Object?> get props => [isLoad, isMore, search];
}

typedef AlbumListState = ListState<AlbumListEvent, ListAlbum>;

class AlbumListBloc extends Bloc<AlbumListEvent, AlbumListState> {
  static final int _firstPageSize = 9;
  static final int _pageSize = 30;

  final ApiRepository api;

  AlbumListBloc(this.api)
      : super(AlbumListState.loading(
          results: [],
          event: AlbumListEvent.load(),
        ));

  @override
  Stream<AlbumListState> mapEventToState(AlbumListEvent event) async* {
    if (event.isLoad) {
      yield* _load(event);
    } else if (event.isMore && !state.isDone) {
      yield* _more(event);
    }
  }

  Stream<AlbumListState> _load(AlbumListEvent event) async* {
    yield state.copyWith(isLoading: true, event: event);
    // await Future.delayed(Duration(seconds: 1));

    try {
      var listResponse = await api.getAlbums(
        search: event.search,
        limit: _firstPageSize,
        offset: 0,
      );
      if (listResponse.results.isNotEmpty) {
        yield AlbumListState.success(
          results: listResponse.results,
          isDone: listResponse.results.length == listResponse.count,
          event: event,
        );
      } else {
        yield AlbumListState.failure(
          message: state.event.search == null
              ? 'There are no members.'
              : 'There are no members found for "${state.event.search}"',
          event: event,
        );
      }
    } on ApiException catch (exception) {
      yield AlbumListState.failure(
        message: _failureMessage(exception),
        event: event,
      );
    }
  }

  Stream<AlbumListState> _more(AlbumListEvent event) async* {
    yield state.copyWith(isLoadingMore: true);
    // await Future.delayed(Duration(seconds: 1));

    try {
      var listResponse = await api.getAlbums(
        search: state.event.search,
        limit: _pageSize,
        offset: state.results.length,
      );
      final albums = state.results + listResponse.results;
      yield AlbumListState.success(
        results: albums,
        isDone: albums.length == listResponse.count,
        event: state.event,
      );
    } on ApiException catch (exception) {
      yield AlbumListState.failure(
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
