import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models/registration_field.dart';

typedef RegistrationFieldsState = DetailState<Map<String, RegistrationField>>;

class RegistrationFieldsCubit extends Cubit<RegistrationFieldsState> {
  final ApiRepository api;

  RegistrationFieldsCubit(this.api)
      : super(const RegistrationFieldsState.loading());

  Future<void> load({required int eventPk, required int registrationPk}) async {
    emit(state.copyWith(isLoading: true));
    try {
      final fields = await api.getRegistrationFields(
        eventPk: eventPk,
        registrationPk: registrationPk,
      );
      emit(RegistrationFieldsState.result(result: fields));
    } on ApiException catch (exception) {
      emit(RegistrationFieldsState.failure(
        message: exception.getMessage(
          notFound: 'The registration does not '
              'exist or does not have any fields.',
        ),
      ));
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
  }
}
