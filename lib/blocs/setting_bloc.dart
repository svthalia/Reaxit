import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/models/setting.dart';

import 'list_event.dart';
import 'list_state.dart';

class SettingEvent extends ListEvent {

  SettingEvent.load() : super.load();
  SettingEvent.more() : super.more();

  @override
  List<Object?> get props => [isLoad, isMore];
}

typedef SettingState = ListState<SettingEvent, Setting>;

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  static final int _firstPageSize = 1;
  static final int _pageSize = 30;

  final ApiRepository api;

  SettingBloc(this.api)
      : super(SettingState.loading(
results: [],
event: SettingEvent.load(),
));

  @override
  Stream<SettingState> mapEventToState(SettingEvent event) async* {
    if (event.isLoad) {
      yield* _load(event);
    }
    else if (event.isMore && !state.isDone) {
      yield* _more(event);
    }
  }

  Stream<SettingState> _load(SettingEvent event) async* {
    yield state.copyWith(isLoading: true, event: event);

    try {
      var listResponse = await api.getDevices(
        limit: _firstPageSize,
        offset: 0,
      );
      if (listResponse.results.isNotEmpty) {
        yield SettingState.success(results: listResponse.results, isDone: listResponse.results.length == listResponse.count, event: event);
      } else {
        yield SettingState.failure(
          message: 'There are no devices.', event: event,
        );
      }
    } on ApiException catch (exception) {
      yield SettingState.failure(
        message: _failureMessage(exception),
        event: event,
      );
    }
  }

  Stream<SettingState> _more(SettingEvent event) async* {
    yield state.copyWith(isLoadingMore: true);

    try {
      var listResponse = await api.getDevices(
        limit: _pageSize,
        offset: state.results.length,
      );
      final albums = state.results + listResponse.results;
      yield SettingState.success(
        results: albums,
        isDone: albums.length == listResponse.count,
        event: state.event,
      );
    } on ApiException catch (exception) {
      yield SettingState.failure(
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