import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs/list_cubit.dart';
import 'package:reaxit/blocs/list_state.dart';
import 'package:reaxit/models.dart';

class EventState extends Equatable {
  /// The event, will only be null if event has not yet been loaded.
  final Event? event;

  /// A message describing why there are no results.
  final String? message;

  /// Different results are being loaded. The results are outdated.
  final bool isLoading;

  const EventState({
    required this.event,
    required this.isLoading,
    required this.message,
  });

  bool get hasException => message != null;

  EventState copyWith({
    Event? event,
    String? message,
    bool? isLoading,
    bool? isDone,
  }) => EventState(
    event: event ?? this.event,
    message: message ?? this.message,
    isLoading: isLoading ?? this.isLoading,
  );

  @override
  List<Object?> get props => [event, message, isLoading];

  @override
  String toString() {
    return 'EventState(isLoading: $isLoading, message: $message, event: $event)';
  }

  const EventState.loading({this.event}) : message = null, isLoading = true;

  const EventState.loadingMore({this.event})
    : message = null,
      isLoading = false;

  const EventState.success({this.event}) : message = null, isLoading = false;

  const EventState.failure({required String this.message})
    : event = null,
      isLoading = false;
}

class EventCubit extends Cubit<EventState> {
  final ApiRepository api;
  final String? _eventSlug;
  int? _eventPk;

  EventCubit(this.api, {int? eventPk, String? eventSlug})
    : assert(!(eventPk == null && eventSlug == null)),
      _eventSlug = eventSlug,
      _eventPk = eventPk,
      super(const EventState.loading());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));

    try {
      Event event = _eventPk == null
          ? await api.getEventBySlug(slug: _eventSlug!)
          : await api.getEventByPk(pk: _eventPk!);

      _eventPk = event.pk;

      if (isClosed) {
        return;
      }

      emit(EventState.success(event: event));
    } on ApiException catch (exception) {
      if (isClosed) {
        // If the cubit is closed, the error does not matter at all
        return;
      }

      emit(
        EventState.failure(
          message: exception.getMessage(notFound: 'The event does not exist.'),
        ),
      );
    }
  }

  /// Register for the [Event] with the `pk`.
  ///
  /// This throws an [ApiException] if registration fails.
  Future<EventRegistration> register() async {
    final registration = await api.registerForEvent(_eventPk!);
    // Reload the event for updated registration status.
    await load();
    return registration;
  }

  /// Cancel the [EventRegistration] with `registrationPk`
  /// for the [Event] with `eventPk`.
  ///
  /// This throws an [ApiException] if deregistering fails.
  Future<void> cancelRegistration({required int registrationPk}) async {
    await api.cancelRegistration(
      eventPk: _eventPk!,
      registrationPk: registrationPk,
    );
    // Reload the event for updated registration status.
    await load();
  }

  /// Pay your registration for the event using Thalia Pay.
  Future<void> thaliaPayRegistration({required int registrationPk}) async {
    await api.thaliaPayRegistration(registrationPk: registrationPk);
    await load();
  }
}

typedef EventListState = ListState<EventRegistration>;

class EventListCubit extends SingleListCubit<EventRegistration> {
  final int _eventPk;

  EventListCubit(super.api, this._eventPk);

  static const int firstPageSize = 30;

  @override
  Future<ListResponse<EventRegistration>> getDown(int offset) {
    assert(searchQuery == null); // We cannot search registrations

    return api.getEventRegistrations(
      pk: _eventPk,
      limit: firstPageSize,
      offset: offset,
    );
  }

  @override
  List<EventRegistration> combineDown(
    List<EventRegistration> downResults,
    ListState<EventRegistration> oldstate,
  ) => oldstate.results + downResults;

  @override
  ListState<EventRegistration> empty(String? query) =>
      const ListState.failure(message: 'No registrations found.');
}
