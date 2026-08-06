import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models.dart';

class UserPayments extends Equatable {
  final PaymentUser user;
  final List<Payment> payments;

  const UserPayments(this.user, this.payments);

  @override
  List<Object?> get props => [user, payments];
}

typedef PaymentUserState = DetailState<UserPayments>;

class PaymentUserCubit extends Cubit<PaymentUserState> {
  final ApiRepository api;

  PaymentUserCubit(this.api) : super(const LoadingState());

  Future<void> load() async {
    emit(LoadingState.from(state));
    try {
      final paymentUser = await api.getPaymentUser();
      final payments = await api.getPayments(
        type: [PaymentType.tpayPayment],
        settled: false,
      );

      emit(ResultState(UserPayments(paymentUser, payments.results)));
    } on ApiException catch (exception) {
      emit(ErrorState(exception.message));
    }
  }
}
