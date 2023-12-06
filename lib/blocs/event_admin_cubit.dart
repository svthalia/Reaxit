import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/config.dart';
import 'package:reaxit/models.dart';

class EventAdminState extends Equatable {
  /// This can only be null when [isLoading] or [hasException] is true.
  final AdminEvent? event;

  /// These may be outdated when [isLoading] is true.
  final List<AdminEventRegistration> registrations;
  final List<AdminEventRegistration> cancelledRegistrations;
  final List<AdminEventRegistration> queuedRegistrations;

  final String? exception;
  final String? message;
  final String? cancelledMessage;
  final String? queuedMessage;
  final bool isLoading;

  bool get hasException => exception != null;

  @protected
  const EventAdminState({
    required this.event,
    required this.registrations,
    required this.cancelledRegistrations,
    required this.queuedRegistrations,
    required this.isLoading,
    required this.exception,
    required this.message,
    required this.cancelledMessage,
    required this.queuedMessage,
  }) : assert(
          event != null || isLoading || message != null,
          'event can only be null when isLoading or hasException is true.',
        );

  @override
  List<Object?> get props => [
        event,
        registrations,
        cancelledRegistrations,
        queuedRegistrations,
        message,
        cancelledMessage,
        queuedMessage,
        isLoading
      ];

  EventAdminState copyWith({
    AdminEvent? event,
    List<AdminEventRegistration>? registrations,
    List<AdminEventRegistration>? cancelledRegistrations,
    List<AdminEventRegistration>? queuedRegistrations,
    bool? isLoading,
    String? exception,
    String? message,
    String? cancelledMessage,
    String? queuedMessage,
  }) =>
      EventAdminState(
        event: event ?? this.event,
        registrations: registrations ?? this.registrations,
        cancelledRegistrations:
            cancelledRegistrations ?? this.cancelledRegistrations,
        queuedRegistrations: queuedRegistrations ?? this.queuedRegistrations,
        isLoading: isLoading ?? this.isLoading,
        exception: exception ?? this.exception,
        message: message ?? this.message,
        cancelledMessage: cancelledMessage ?? this.cancelledMessage,
        queuedMessage: queuedMessage ?? this.queuedMessage,
      );

  const EventAdminState.result({
    required AdminEvent this.event,
    required this.registrations,
    required this.cancelledRegistrations,
    required this.queuedRegistrations,
    this.exception,
    this.message,
    this.cancelledMessage,
    this.queuedMessage,
  }) : isLoading = false;

  const EventAdminState.loading(
      {this.event,
      required this.registrations,
      required this.cancelledRegistrations,
      required this.queuedRegistrations})
      : exception = null,
        message = null,
        cancelledMessage = null,
        queuedMessage = null,
        isLoading = true;

  const EventAdminState.failure({required String this.exception, this.event})
      : registrations = const [],
        cancelledRegistrations = const [],
        queuedRegistrations = const [],
        isLoading = false,
        message = null,
        cancelledMessage = null,
        queuedMessage = null;
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
  }) : super(const EventAdminState.loading(
            registrations: [],
            cancelledRegistrations: [],
            queuedRegistrations: []));

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final query = _searchQuery;
      final event = await api.getAdminEvent(pk: eventPk);
      final registrations = await api.getAdminEventRegistrations(
        pk: eventPk,
        search: query,
        limit: 999999999,
        cancelled: false,
        queued: false,
      );
      final cancelledRegistrations = await api.getAdminEventRegistrations(
        pk: eventPk,
        search: query,
        limit: 999999999,
        cancelled: true,
        ordering: '-date_cancelled',
      );
      final queuedRegistrations = await api.getAdminEventRegistrations(
        pk: eventPk,
        search: query,
        limit: 999999999,
        queued: true,
        ordering: 'queue_position',
      );

      // Discard result if _searchQuery has
      // changed since the request was made.
      if (query != _searchQuery) return;

      // temporary fix, remove when api is updated
      registrations.results.removeWhere((r) => r.queuePosition != null);

      String? message;
      if (registrations.results.isEmpty) {
        message = (query?.isEmpty ?? true)
            ? 'There are no registrations.'
            : 'There are no registrations matching "$query".';
      }
      String? cancelledMessage;
      if (cancelledRegistrations.results.isEmpty) {
        cancelledMessage = (query?.isEmpty ?? true)
            ? 'There are no cancelled registrations.'
            : 'There are no cancelled registrations matching "$query".';
      }
      String? queuedMessage;
      if (queuedRegistrations.results.isEmpty) {
        queuedMessage = (query?.isEmpty ?? true)
            ? 'There are no queued registrations.'
            : 'There are no queued registrations matching "$query".';
      }

      emit(EventAdminState.result(
        event: event,
        registrations: registrations.results,
        cancelledRegistrations: cancelledRegistrations.results,
        queuedRegistrations: queuedRegistrations.results,
        message: message,
        cancelledMessage: cancelledMessage,
        queuedMessage: queuedMessage,
      ));
    } on ApiException catch (exception) {
      emit(EventAdminState.failure(
        exception: exception.getMessage(notFound: 'The event does not exist.'),
      ));
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
          limit: 999999999,
          cancelled: false,
          queued: false,
        );
        final cancelledRegistrations = await api.getAdminEventRegistrations(
          pk: eventPk,
          search: query,
          limit: 999999999,
          cancelled: true,
          ordering: '-date_cancelled',
        );
        final queuedRegistrations = await api.getAdminEventRegistrations(
          pk: eventPk,
          search: query,
          limit: 999999999,
          queued: true,
          ordering: 'queue_position',
        );

        // Discard result if _searchQuery has
        // changed since the request was made.
        if (query != _searchQuery) return;

        // temporary fix, remove when api is updated
        registrations.results.removeWhere((r) => r.queuePosition != null);

        String? message;
        if (registrations.results.isEmpty) {
          message = (query?.isEmpty ?? true)
              ? 'There are no registrations.'
              : 'There are no registrations matching "$query".';
        }
        String? cancelledMessage;
        if (cancelledRegistrations.results.isEmpty) {
          cancelledMessage = (query?.isEmpty ?? true)
              ? 'There are no cancelled registrations.'
              : 'There are no cancelled registrations matching "$query".';
        }
        String? queuedMessage;
        if (queuedRegistrations.results.isEmpty) {
          queuedMessage = (query?.isEmpty ?? true)
              ? 'There are no queued registrations.'
              : 'There are no queued registrations matching "$query".';
        }

        emit(EventAdminState.result(
          event: event,
          registrations: registrations.results,
          cancelledRegistrations: cancelledRegistrations.results,
          queuedRegistrations: queuedRegistrations.results,
          message: message,
          cancelledMessage: cancelledMessage,
          queuedMessage: queuedMessage,
        ));
      } on ApiException catch (exception) {
        emit(EventAdminState.failure(
          exception:
              exception.getMessage(notFound: 'The event does not exist.'),
        ));
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
          cancelledRegistrations: const [],
          queuedRegistrations: const [],
        ));
      } else {
        _searchDebounceTimer = Timer(
          Config.searchDebounceTime,
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
}
