import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models/payment_user.dart';

typedef PaymentUserState = DetailState<PaymentUser>;

class PaymentUserCubit extends Cubit<PaymentUserState> {
  final ApiRepository api;

  PaymentUserCubit(this.api) : super(PaymentUserState.loading());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final paymentUser = await api.getPaymentUser();
      emit(PaymentUserState.result(result: paymentUser));
    } on ApiException catch (exception) {
      emit(PaymentUserState.failure(message: _failureMessage(exception)));
    }
  }

  String _failureMessage(ApiException exception) {
    switch (exception) {
      case ApiException.noInternet:
        return 'Not connected to the internet.';
      default:
        return 'An unknown error occurred.';
    }
  }
}
