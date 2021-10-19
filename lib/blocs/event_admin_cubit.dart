import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:reaxit/api_repository.dart';
import 'package:reaxit/config.dart' as config;
import 'package:reaxit/models/event.dart';
import 'package:reaxit/models/event_registration.dart';
import 'package:reaxit/models/payment.dart';

class EventAdminState extends Equatable {
  /// This can only be null when [isLoading] or [hasException] is true.
  final Event? event;

  /// These may be outdated when [isLoading] is true.
  final List<AdminEventRegistration> registrations;

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
          event != null || isLoading || message != null,
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
    required this.registrations,
  })  : message = null,
        isLoading = false;

  const EventAdminState.loading({this.event, required this.registrations})
      : message = null,
        isLoading = true;

  const EventAdminState.failure({required String this.message})
      : event = null,
        registrations = const [],
        isLoading = false;
}

class EventAdminCubit extends Cubit<EventAdminState> {
  final ApiRepository api;
  final int eventPk;

  /// The last used search query. Can be set through `this.search(query)`.
  String? _searchQuery;

  /// The last used search query. Can be set through `this.search(query)`.
  String? get searchQuery => _searchQuery;

  /// A timer used to debounce calls to `loadRegistrations()` from `search()`.
  Timer? _searchDebounceTimer;

  EventAdminCubit(
    this.api, {
    required this.eventPk,
  }) : super(const EventAdminState.loading(registrations: []));

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
  void search(String? query) {
    if (query != _searchQuery) {
      _searchQuery = query;
      _searchDebounceTimer?.cancel();
      if (query?.isEmpty ?? false) {
        /// Don't get results when the query is empty.
        emit(EventAdminState.loading(
          event: state.event,
          registrations: const [],
        ));
      } else {
        _searchDebounceTimer = Timer(
          config.searchDebounceTime,
          loadRegistrations,
        );
      }
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
    if (state.registrations.isNotEmpty) {
      emit(state.copyWith(
        registrations: state.registrations.map(
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
      if (state.registrations.isNotEmpty) {
        emit(
          state.copyWith(
            registrations: state.registrations.map(
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
      if (state.registrations.isNotEmpty) {
        emit(
          state.copyWith(
            registrations: state.registrations.map(
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
}
