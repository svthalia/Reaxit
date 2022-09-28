import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';

typedef PaymentUserState = DetailState<PaymentUser>;

class PaymentUserCubit extends Cubit<PaymentUserState> {
  final ApiRepository api;

  PaymentUserCubit(this.api) : super(const PaymentUserState.loading());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final paymentUser = await api.getPaymentUser();
      emit(PaymentUserState.result(result: paymentUser));
    } on ApiException catch (exception) {
      emit(PaymentUserState.failure(message: exception.message));
    }
  }
}
