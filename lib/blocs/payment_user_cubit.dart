import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';

typedef PaymentUserState = DetailState<PaymentUser>;

class PaymentUserCubit extends Cubit<PaymentUserState> {
  final ApiRepository api;

  PaymentUserCubit(this.api) : super(const LoadingState());

  Future<void> load() async {
    emit(LoadingState.from(state));
    try {
      final paymentUser = await api.getPaymentUser();
      emit(ResultState(paymentUser));
    } on ApiException catch (exception) {
      emit(ErrorState(exception.message));
    }
  }
}
