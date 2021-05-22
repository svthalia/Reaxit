import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models/registration_field.dart';

class RegistrationFieldsCubit
    extends Cubit<DetailState<Map<String, RegistrationField>>> {
  final ApiRepository api;

  RegistrationFieldsCubit(this.api) : super(DetailState.loading());

  Future<void> load({required int eventPk, required int registrationPk}) async {
    emit(state.copyWith(isLoading: true));
    try {
      final fields = await api.getRegistrationFields(
        eventPk: eventPk,
        registrationPk: registrationPk,
      );
      emit(DetailState.result(result: fields));
    } on ApiException catch (exception) {
      emit(DetailState.failure(message: _failureMessage(exception)));
    }
  }

  Future<void> update({
    required int eventPk,
    required int registrationPk,
    required Map<String, RegistrationField> fields,
  }) async {
    await api.updateRegistrationFields(
      eventPk: eventPk,
      registrationPk: registrationPk,
      fields: fields,
    );
    // await load(eventPk: eventPk, registrationPk: registrationPk);
  }

  String _failureMessage(ApiException exception) {
    switch (exception) {
      case ApiException.noInternet:
        return 'Not connected to the internet.';
      case ApiException.notFound:
        return 'The registration does not exist or does not have any fields.';
      default:
        return 'An unknown error occurred.';
    }
  }
}