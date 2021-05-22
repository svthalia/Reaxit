import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models/event.dart';

typedef WelcomeState = DetailState<List<Event>>;

class WelcomeCubit extends Cubit<WelcomeState> {
  final ApiRepository api;

  WelcomeCubit(this.api) : super(WelcomeState.loading());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final eventsResponse = await api.getEvents(
        start: DateTime.now(),
        limit: 3,
      );
      if (eventsResponse.results.isNotEmpty) {
        emit(WelcomeState.result(result: eventsResponse.results));
      } else {
        emit(WelcomeState.failure(message: 'There are no upcoming events.'));
      }
    } on ApiException catch (exception) {
      emit(WelcomeState.failure(message: _failureMessage(exception)));
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
