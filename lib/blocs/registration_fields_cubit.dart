import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';

typedef RegistrationFieldsState = DetailState<Map<String, RegistrationField>>;

class RegistrationFieldsCubit extends Cubit<RegistrationFieldsState> {
  final ApiRepository api;

  RegistrationFieldsCubit(this.api) : super(const LoadingState());

  Future<void> load({required int eventPk, required int registrationPk}) async {
    emit(LoadingState.from(state));
    try {
      final fields = await api.getRegistrationFields(
        eventPk: eventPk,
        registrationPk: registrationPk,
      );
      emit(ResultState(fields));
    } on ApiException catch (exception) {
      emit(
        ErrorState(
          exception.getMessage(
            notFound:
                'The registration does not '
                'exist or does not have any fields.',
          ),
        ),
      );
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
