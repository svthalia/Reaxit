import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:reaxit/api_repository.dart';
import 'package:reaxit/models/event.dart';
import 'package:reaxit/models/event_registration.dart';
import 'package:reaxit/models/payment.dart';

class EventAdminState extends Equatable {
  /// This can only be null when [isLoading] or [hasException] is true.
  final Event? event;

  /// This can only be null when [isLoading] or [hasException] is true.
  final List<AdminEventRegistration>? registrations;

  final String? message;
  final bool isLoading;

  bool get hasException => message != null;

  @protected
  const EventAdminState({
    required this.event,
    required this.registrations,
    required this.isLoading,
    required this.message,
  }) : assert(
          (event != null && registrations != null) ||
              isLoading ||
              message != null,
          'event can only be null when isLoading or hasException is true.',
        );

  @override
  List<Object?> get props => [event, registrations, message, isLoading];

  EventAdminState copyWith({
    Event? event,
    List<AdminEventRegistration>? registrations,
    bool? isLoading,
    String? message,
  }) =>
      EventAdminState(
        event: event ?? this.event,
        registrations: registrations ?? this.registrations,
        isLoading: isLoading ?? this.isLoading,
        message: message ?? this.message,
      );

  const EventAdminState.result({
    required Event this.event,
    required List<AdminEventRegistration> this.registrations,
  })  : message = null,
        isLoading = false;

  const EventAdminState.loading({this.event, this.registrations})
      : message = null,
        isLoading = true;

  const EventAdminState.failure({required String this.message})
      : event = null,
        registrations = null,
        isLoading = false;
}

class EventAdminCubit extends Cubit<EventAdminState> {
  final ApiRepository api;
  final int eventPk;

  /// The last used search query. Can be set through `this.search(query)`.
  String? _searchQuery;

  String? get searchQuery => _searchQuery;

  EventAdminCubit(
    this.api, {
    required this.eventPk,
  }) : super(const EventAdminState.loading());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final query = _searchQuery;
      final event = await api.getEvent(pk: eventPk);
      final registrations = await api.getAdminEventRegistrations(
        pk: eventPk,
        search: query,
      );
      if (registrations.results.isEmpty) {
        if (query?.isEmpty ?? true) {
          emit(const EventAdminState.failure(
            message: 'There are no registrations.',
          ));
        } else {
          emit(EventAdminState.failure(
            message: 'There are no registrations matching "$query".',
          ));
        }
      } else {
        emit(EventAdminState.result(
          event: event,
          registrations: registrations.results,
        ));
      }
    } on ApiException catch (exception) {
      emit(EventAdminState.failure(message: _failureMessage(exception)));
    }
  }

  Future<void> loadRegistrations() async {
    if (!state.hasException && !state.isLoading) {
      final event = state.event!;
      emit(state.copyWith(isLoading: true));
      try {
        final query = _searchQuery;
        final registrations = await api.getAdminEventRegistrations(
          pk: eventPk,
          search: query,
        );
        if (registrations.results.isEmpty) {
          if (query?.isEmpty ?? true) {
            emit(const EventAdminState.failure(
              message: 'There are no registrations.',
            ));
          } else {
            emit(EventAdminState.failure(
              message: 'There are no registrations matching "$query".',
            ));
          }
        } else {
          emit(EventAdminState.result(
            event: event,
            registrations: registrations.results,
          ));
        }
      } on ApiException catch (exception) {
        emit(EventAdminState.failure(message: _failureMessage(exception)));
      }
    } else {
      load();
    }
  }

  /// Set this cubit's `searchQuery` and load the registrations for that query.
  ///
  /// Use `null` as argument to remove the search query.
  Future<void> search(String? query) async {
    // TODO: Debounce the call to load: e.g. wait for 100ms and then load,
    //  saving a future so that later `search` calls within the 100ms wait
    //  do not trigger an additional `loadRegistrations` call.
    if (query != _searchQuery) {
      _searchQuery = query;
      await loadRegistrations();
    }
  }

  Future<void> setPresent({
    required int registrationPk,
    required bool present,
  }) async {
    await api.markPresentAdminEventRegistration(
      eventPk: eventPk,
      registrationPk: registrationPk,
      present: present,
    );
    if (state.registrations != null) {
      emit(state.copyWith(
        registrations: state.registrations!.map(
          (registration) {
            if (registration.pk == registrationPk) {
              return registration.copyWithPresent(present);
            } else {
              return registration;
            }
          },
        ).toList(),
      ));
    } else {
      await load();
    }
  }

  Future<void> setPayment({
    required int registrationPk,
    required PaymentType? paymentType,
  }) async {
    if (paymentType != null) {
      final payable = await api.markPaidAdminEventRegistration(
        registrationPk: registrationPk,
        paymentType: paymentType,
      );
      if (state.registrations != null) {
        emit(
          state.copyWith(
            registrations: state.registrations!.map(
              (registration) {
                if (registration.pk == registrationPk) {
                  return registration.copyWithPayment(payable.payment);
                } else {
                  return registration;
                }
              },
            ).toList(),
          ),
        );
      } else {
        await load();
      }
    } else {
      await api.markNotPaidAdminEventRegistration(
        registrationPk: registrationPk,
      );
      if (state.registrations != null) {
        emit(
          state.copyWith(
            registrations: state.registrations!.map(
              (registration) {
                if (registration.pk == registrationPk) {
                  return registration.copyWithPayment(null);
                } else {
                  return registration;
                }
              },
            ).toList(),
          ),
        );
      } else {
        await load();
      }
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

  // TODO: Change other cubits to use the search mechanism used here.
}
