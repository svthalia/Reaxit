import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models/payable.dart';

typedef SalesOrderState = DetailState<Payable>;

class SalesOrderCubit extends Cubit<SalesOrderState> {
  final ApiRepository api;

  SalesOrderCubit(this.api) : super(const SalesOrderState.loading());

  Future<void> load(String pk) async {
    emit(state.copyWith(isLoading: true));
    try {
      final payable = await api.getSalesOrderPayable(salesOrderPk: pk);
      emit(SalesOrderState.result(result: payable));
    } on ApiException catch (exception) {
      emit(SalesOrderState.failure(message: _failureMessage(exception)));
    }
  }

  Future<void> paySalesOrder(String pk) async {
    await api.thaliaPaySalesOrder(salesOrderPk: pk);
  }

  String _failureMessage(ApiException exception) {
    switch (exception) {
      case ApiException.noInternet:
        return 'Not connected to the internet.';
      case ApiException.notFound:
        return 'The order does not exist.';
      default:
        return 'An unknown error occurred.';
    }
  }
}
