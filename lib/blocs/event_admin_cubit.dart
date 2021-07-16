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

  EventAdminState.result({
    required Event event,
    required List<AdminEventRegistration> registrations,
  })  : event = event,
        registrations = registrations,
        message = null,
        isLoading = false;

  EventAdminState.loading({this.event, this.registrations})
      : message = null,
        isLoading = true;

  EventAdminState.failure({required String message})
      : event = null,
        registrations = null,
        message = message,
        isLoading = false;
}

class EventAdminCubit extends Cubit<EventAdminState> {
  final ApiRepository api;
  final int eventPk;

  EventAdminCubit(
    this.api, {
    required this.eventPk,
  }) : super(EventAdminState.loading());

  Future<void> load({String? search}) async {
    emit(state.copyWith(isLoading: true));
    try {
      final event = await api.getEvent(pk: eventPk);
      final registrations =
          await api.getAdminEventRegistrations(pk: eventPk, search: search);
      if (registrations.results.isEmpty) {
        emit(EventAdminState.failure(message: 'There are no registrations'));
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
}
