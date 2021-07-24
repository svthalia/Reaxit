import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api_repository.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models/food_order.dart';
import 'package:reaxit/models/payment.dart';

typedef FoodAdminState = DetailState<List<FoodOrder>>;

class FoodAdminCubit extends Cubit<FoodAdminState> {
  final ApiRepository api;
  final int foodEventPk;

  FoodAdminCubit(
    this.api, {
    required this.foodEventPk,
  }) : super(const FoodAdminState.loading());

  Future<void> load({String? search}) async {
    emit(state.copyWith(isLoading: true));
    try {
      final orders =
          await api.getAdminFoodOrders(pk: foodEventPk, search: search);
      if (orders.results.isEmpty) {
        emit(const FoodAdminState.failure(message: 'There are no orders'));
      } else {
        emit(FoodAdminState.result(result: orders.results));
      }
    } on ApiException catch (exception) {
      emit(FoodAdminState.failure(message: _failureMessage(exception)));
    }
  }

  Future<void> setPayment({
    required int orderPk,
    required PaymentType? paymentType,
  }) async {
    if (paymentType != null) {
      final payable = await api.markPaidAdminFoodOrder(
        orderPk: orderPk,
        paymentType: paymentType,
      );
      if (state.result != null) {
        emit(
          state.copyWith(
            result: state.result!.map(
              (order) {
                if (order.pk == orderPk) {
                  return order.copyWithPayment(payable.payment);
                } else {
                  return order;
                }
              },
            ).toList(),
          ),
        );
      } else {
        await load();
      }
    } else {
      await api.markNotPaidAdminFoodOrder(
        orderPk: orderPk,
      );
      if (state.result != null) {
        emit(
          state.copyWith(
            result: state.result!.map(
              (order) {
                if (order.pk == orderPk) {
                  return order.copyWithPayment(null);
                } else {
                  return order;
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
        return 'The food event does not exist.';
      default:
        return 'An unknown error occurred.';
    }
  }
}
