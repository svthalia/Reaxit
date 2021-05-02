import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
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

// TODO: when dart 2.13 becomes the standard, replace this entire class by a typedef. Currently typedefs can only be used on function signatures.
class AlbumListState extends ListState<AlbumListEvent, ListAlbum> {
  @protected
  AlbumListState({
    required List<ListAlbum> results,
    required String? message,
    required bool isLoading,
    required bool isLoadingMore,
    required bool isDone,
    required AlbumListEvent event,
  }) : super(
          results: results,
          message: message,
          isLoading: isLoading,
          isLoadingMore: isLoadingMore,
          isDone: isDone,
          event: event,
        );

  @override
  AlbumListState copyWith({
    List<ListAlbum>? results,
    String? message,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isDone,
    AlbumListEvent? event,
  }) =>
      AlbumListState(
        results: results ?? this.results,
        message: message ?? this.message,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        isDone: isDone ?? this.isDone,
        event: event ?? this.event,
      );

  AlbumListState.failure({
    required String message,
    required AlbumListEvent event,
  }) : super.failure(message: message, event: event);

  AlbumListState.loading({
    required List<ListAlbum> results,
    required AlbumListEvent event,
  }) : super.loading(results: results, event: event);

  AlbumListState.loadingMore({
    required List<ListAlbum> results,
    required AlbumListEvent event,
  }) : super.loadingMore(results: results, event: event);

  AlbumListState.success({
    required List<ListAlbum> results,
    required AlbumListEvent event,
    required bool isDone,
  }) : super.success(results: results, event: event, isDone: isDone);
}

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
              ? 'There are no albums.'
              : 'There are no albums found for "${state.event.search}"',
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
