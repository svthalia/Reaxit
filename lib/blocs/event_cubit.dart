import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';

typedef EventState = DetailState<Event>;

class EventCubit extends Cubit<EventState> {
  final ApiRepository api;
  final int eventPk;

  // TODO: Someday: combine with RegistrationsCubit.

  EventCubit(this.api, {required this.eventPk})
      : super(const EventState.loading());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final event = await api.getEvent(pk: eventPk);
      emit(EventState.result(result: event));
    } on ApiException catch (exception) {
      emit(EventState.failure(
        message: exception.getMessage(notFound: 'The event does not exist.'),
      ));
    }
  }

  /// Register for the [Event] with the `pk`.
  ///
  /// This throws an [ApiException] if registration fails.
  Future<EventRegistration> register() async {
    final registration = await api.registerForEvent(eventPk);
    // Reload the event for updated registration status.
    await load();
    return registration;
  }

  /// Cancel the [EventRegistration] with `registrationPk`
  /// for the [Event] with `eventPk`.
  ///
  /// This throws an [ApiException] if deregistering fails.
  Future<void> cancelRegistration({
    required int registrationPk,
  }) async {
    await api.cancelRegistration(
      eventPk: eventPk,
      registrationPk: registrationPk,
    );
    // Reload the event for updated registration status.
    await load();
  }

  /// Pay your registration for the event using Thalia Pay.
  Future<void> thaliaPayRegistration({
    required int registrationPk,
  }) async {
    await api.thaliaPayRegistration(registrationPk: registrationPk);
    await load();
  }
}
