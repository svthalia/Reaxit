import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/models.dart';

class PaymentUserState extends Equatable {
  /// This can only be null when [isLoading] or [hasException] is true.
  final PaymentUser? user;

  /// This can only be null when [isLoading] or [hasException] is true.
  final List<Payment>? payments;

  /// A message describing why there are no foodEvents.
  final String? message;

  final bool isLoading;

  bool get hasException => message != null;

  @protected
  const PaymentUserState({
    required this.user,
    required this.payments,
    required this.isLoading,
    required this.message,
  }) : assert(
         (user != null && payments != null) || isLoading || message != null,
         'user and payments can only be null '
         'when isLoading or hasException is true.',
       );

  @override
  List<Object?> get props => [user, payments, message, isLoading];

  PaymentUserState copyWith({
    PaymentUser? user,
    List<Payment>? payments,
    bool? isLoading,
    String? message,
  }) => PaymentUserState(
    user: user ?? this.user,
    payments: payments ?? this.payments,
    isLoading: isLoading ?? this.isLoading,
    message: message ?? this.message,
  );

  const PaymentUserState.result({
    required PaymentUser this.user,
    required List<Payment> this.payments,
  }) : message = null,
       isLoading = false;

  const PaymentUserState.loading({this.user, this.payments})
    : message = null,
      isLoading = true;

  const PaymentUserState.failure({required String this.message})
    : user = null,
      payments = null,
      isLoading = false;
}

class PaymentUserCubit extends Cubit<PaymentUserState> {
  final ApiRepository api;

  PaymentUserCubit(this.api) : super(const PaymentUserState.loading());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      final paymentUser = await api.getPaymentUser();
      final payments = await api.getPayments(
        type: [PaymentType.tpayPayment],
        settled: false,
      );

      emit(
        PaymentUserState.result(user: paymentUser, payments: payments.results),
      );
    } on ApiException catch (exception) {
      emit(PaymentUserState.failure(message: exception.message));
    }
  }
}
