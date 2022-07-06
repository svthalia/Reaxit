import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models/sales_order.dart';

typedef SalesOrderState = DetailState<SalesOrder>;

class SalesOrderCubit extends Cubit<SalesOrderState> {
  final ApiRepository api;

  SalesOrderCubit(this.api) : super(const SalesOrderState.loading());

  Future<void> load(String pk) async {
    emit(state.copyWith(isLoading: true));
    try {
      final order = await api.claimSalesOrder(pk: pk);
      emit(SalesOrderState.result(result: order));
    } on ApiException catch (exception) {
      emit(SalesOrderState.failure(
        message: exception.getMessage(notFound: 'The order does not exist.'),
      ));
    }
  }

  Future<void> paySalesOrder(String pk) async {
    await api.thaliaPaySalesOrder(salesOrderPk: pk);
  }
}
