import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models/event.dart';

class EventCubit extends Cubit<DetailState<Event>> {
  final ApiRepository api;

  EventCubit(this.api) : super(DetailState<Event>.loading());

  Future<void> load(int pk) async {
    emit(state.copyWith(isLoading: true));
    try {
      final event = await api.getEvent(pk: pk);
      emit(DetailState.result(result: event));
    } on ApiException catch (exception) {
      emit(DetailState.failure(message: _failureMessage(exception)));
    }
  }

  String _failureMessage(ApiException exception) {
    switch (exception) {
      case ApiException.noInternet:
        return 'Not connected to the internet.';
      case ApiException.notFound:
        return 'The event does not exist.';
      default:
        return 'An unknown error occurred.';
    }
  }
}
