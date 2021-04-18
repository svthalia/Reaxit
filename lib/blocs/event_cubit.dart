import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/models/event_registration.dart';

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

  /// Register for the [Event] with the `pk`.
  ///
  /// This throws an [ApiException] if registration fails.
  Future<EventRegistration> register(int pk) async {
    final registration = await api.registerForEvent(pk);
    // Reload the event for updated registration status.
    await load(pk);
    return registration;
  }

  /// Cancel your registration for the [Event] with the `pk`.
  ///
  /// This throws an [ApiException] if deregistering fails.
  Future<void> cancelRegistration(int pk) async {
    await api.cancelRegistrationForEvent(pk);
    // Reload the event for updated registration status.
    await load(pk);
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
