import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api_repository.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models/event_registration.dart';

typedef RegistrationsState = DetailState<List<EventRegistration>>;

class RegistrationsCubit extends Cubit<RegistrationsState> {
  final ApiRepository api;

  RegistrationsCubit(this.api) : super(RegistrationsState.loading());

  Future<void> load(int pk) async {
    emit(state.copyWith(isLoading: true));
    try {
      final listResponse = await api.getEventRegistrations(pk: pk);
      if (listResponse.results.isNotEmpty) {
        emit(RegistrationsState.result(result: listResponse.results));
      } else {
        emit(RegistrationsState.failure(
          message: 'There are no registrations yet.',
        ));
      }
    } on ApiException catch (exception) {
      emit(RegistrationsState.failure(message: _failureMessage(exception)));
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
