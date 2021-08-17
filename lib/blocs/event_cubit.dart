import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api_repository.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/models/event_registration.dart';

typedef EventState = DetailState<Event>;

class EventCubit extends Cubit<EventState> {
  final ApiRepository api;

  // TODO: Include event pk in constructor, and remove it from all methods.
  // TODO: Maybe: combine with RegistrationsCubit.

  EventCubit(this.api) : super(const EventState.loading());

  Future<void> load(int pk) async {
    emit(state.copyWith(isLoading: true));
    try {
      final event = await api.getEvent(pk: pk);
      emit(EventState.result(result: event));
    } on ApiException catch (exception) {
      emit(EventState.failure(message: _failureMessage(exception)));
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

  /// Cancel the [EventRegistration] with `registrationPk`
  /// for the [Event] with `eventPk`.
  ///
  /// This throws an [ApiException] if deregistering fails.
  Future<void> cancelRegistration({
    required int eventPk,
    required int registrationPk,
  }) async {
    await api.cancelRegistration(
      eventPk: eventPk,
      registrationPk: registrationPk,
    );
    // Reload the event for updated registration status.
    await load(eventPk);
  }

  /// Pay your registration for the event using Thalia Pay.
  Future<void> thaliaPayRegistration({
    required int eventPk,
    required int registrationPk,
  }) async {
    await api.thaliaPayRegistration(registrationPk: registrationPk);
    await load(eventPk);
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
