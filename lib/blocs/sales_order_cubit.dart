import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';

typedef SalesOrderState = DetailState<SalesOrder>;

class SalesOrderCubit extends Cubit<SalesOrderState> {
  final ApiRepository api;

  SalesOrderCubit(this.api) : super(const LoadingState());

  Future<void> load(String pk) async {
    emit(LoadingState.from(state));
    try {
      final order = await api.claimSalesOrder(pk: pk);
      emit(ResultState(order));
    } on ApiException catch (exception) {
      emit(
        ErrorState(exception.getMessage(notFound: 'The order does not exist.')),
      );
    }
  }

  Future<void> paySalesOrder(String pk) async {
    await api.thaliaPaySalesOrder(salesOrderPk: pk);
  }
}
