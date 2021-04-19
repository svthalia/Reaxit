import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models/event.dart';

class WelcomeCubit extends Cubit<DetailState<List<Event>>> {
  final ApiRepository api;

  WelcomeCubit(this.api) : super(DetailState<List<Event>>.loading());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final eventsResponse = await api.getEvents(
        start: DateTime.now(),
        limit: 3,
      );
      if (eventsResponse.results.isNotEmpty) {
        emit(DetailState.result(result: eventsResponse.results));
      } else {
        emit(DetailState.failure(message: 'There are no upcoming events.'));
      }
    } on ApiException catch (exception) {
      emit(DetailState.failure(message: _failureMessage(exception)));
    }
  }

  String _failureMessage(ApiException exception) {
    switch (exception) {
      // case ApiException.noInternet:
      //   return 'Not connected to the internet.';
      // case ApiException.notFound:
      //   return 'The member does not exist.';
      default:
        return 'An unknown error occurred.';
    }
  }
}
