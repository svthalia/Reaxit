import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/models.dart';

class EventState extends Equatable {
  final Event? event;
  final List<EventRegistration> registrations;

  /// A message describing why there are no results.
  final String? message;

  /// Different results are being loaded. The results are outdated.
  final bool isLoading;

  /// More of the same results are being loaded. The results are not outdated.
  final bool isLoadingMore;

  /// The last results have been loaded. There are no more pages left.
  final bool isDone;

  const EventState({
    required this.event,
    required this.registrations,
    required this.isLoading,
    required this.message,
    required this.isLoadingMore,
    required this.isDone,
  });

  bool get hasException => message != null;

  EventState copyWith({
    Event? event,
    List<EventRegistration>? registrations,
    String? message,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isDone,
  }) =>
      EventState(
        event: event ?? this.event,
        registrations: registrations ?? this.registrations,
        message: message ?? this.message,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        isDone: isDone ?? this.isDone,
      );

  @override
  List<Object?> get props => [
        event,
        registrations,
        message,
        isLoading,
        isLoadingMore,
        isDone,
      ];

  @override
  String toString() {
    // return 'EventState(isLoading: $isLoading, isLoadingMore: $isLoadingMore,'
    //     ' isDone: $isDone, message: $message, ${results.length} ${T}s)';
    return '';
  }

  const EventState.loading({required this.event, required this.registrations})
      : message = null,
        isLoading = true,
        isLoadingMore = false,
        isDone = true;

  const EventState.loadingMore(
      {required this.event, required this.registrations})
      : message = null,
        isLoading = false,
        isLoadingMore = true,
        isDone = true;

  const EventState.success({
    required this.event,
    required this.registrations,
    required this.isDone,
  })  : message = null,
        isLoading = false,
        isLoadingMore = false;

  const EventState.failure({required String this.message})
      : event = null,
        registrations = const [],
        isLoading = false,
        isLoadingMore = false,
        isDone = true;
}

class EventCubit extends Cubit<EventState> {
  final ApiRepository api;
  final String? eventSlug;
  int? eventPk;

  static const int firstPageSize = 60;
  static const int pageSize = 30;

  /// The offset to be used for the next paginated request.
  int _nextOffset = 0;

  EventCubit(this.api, {required this.eventPk, required this.eventSlug})
      : assert((eventPk == null && eventSlug != null) ||
            (eventPk != null && eventSlug == null)),
        super(const EventState.loading(registrations: [], event: null));

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));

    try {
      Event event = eventPk == null
          ? await api.getEventBySlug(slug: eventSlug!)
          : await api.getEventByPk(pk: eventPk!);

      eventPk = event.pk;

      final listResponse = await api.getEventRegistrations(
          pk: eventPk!, limit: firstPageSize, offset: 0);

      final isDone = listResponse.results.length == listResponse.count;

      _nextOffset = firstPageSize;

      emit(EventState.success(
          event: event, registrations: listResponse.results, isDone: isDone));
    } on ApiException catch (exception) {
      emit(EventState.failure(
          message: exception.getMessage(
        notFound: 'The event does not exist.',
      )));
    }
  }

  /// Register for the [Event] with the `pk`.
  ///
  /// This throws an [ApiException] if registration fails.
  Future<EventRegistration> register() async {
    final registration = await api.registerForEvent(eventPk!);
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
      eventPk: eventPk!,
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

  Future<void> more() async {
    final oldState = state;

    if (oldState.isDone || oldState.isLoading || oldState.isLoadingMore) return;

    emit(oldState.copyWith(isLoadingMore: true));

    try {
      var listResponse = await api.getEventRegistrations(
        pk: eventPk!,
        limit: pageSize,
        offset: _nextOffset,
      );

      final registrations = state.registrations + listResponse.results;
      final isDone = registrations.length == listResponse.count;

      _nextOffset += pageSize;

      emit(EventState.success(
          event: oldState.event, registrations: registrations, isDone: isDone));
    } on ApiException catch (exception) {
      emit(EventState.failure(
        message: exception.getMessage(notFound: 'The event does not exist.'),
      ));
    }
  }
}
