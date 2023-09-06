import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/config.dart';
import 'package:reaxit/blocs.dart';
import 'package:reaxit/models.dart';

typedef FoodAdminState = DetailState<List<AdminFoodOrder>>;

class FoodAdminCubit extends Cubit<FoodAdminState> {
  final ApiRepository api;
  final int foodEventPk;

  /// The last used search query. Can be set through `this.search(query)`.
  String? _searchQuery;

  /// The last used search query. Can be set through `this.search(query)`.
  String? get searchQuery => _searchQuery;

  /// A timer used to debounce calls to `this.load()` from `this.search()`.
  Timer? _searchDebounceTimer;

  FoodAdminCubit(this.api, {required this.foodEventPk})
      : super(const LoadingState());

  Future<void> load() async {
    emit(LoadingState.from(state));
    try {
      final query = _searchQuery;
      final orders = await api.getAdminFoodOrders(
        pk: foodEventPk,
        search: query,
        limit: 999999999,
      );

      // Discard result if _searchQuery has
      // changed since the request was made.
      if (query != _searchQuery) return;

      if (orders.results.isEmpty) {
        if (query?.isEmpty ?? true) {
          emit(const ErrorState('There are no orders.'));
        } else {
          emit(ErrorState('There are no orders matching "$query".'));
        }
      } else {
        emit(ResultState(orders.results));
      }
    } on ApiException catch (exception) {
      emit(ErrorState(exception.getMessage(
        notFound: 'The food event does not exist.',
      )));
    }
  }

  /// Set this cubit's `searchQuery` and load the orders for that query.
  ///
  /// Use `null` as argument to remove the search query.
  void search(String? query) {
    if (query != _searchQuery) {
      _searchQuery = query;
      _searchDebounceTimer?.cancel();
      if (query?.isEmpty ?? false) {
        /// Don't get results when the query is empty.
        emit(const LoadingState());
      } else {
        _searchDebounceTimer = Timer(Config.searchDebounceTime, load);
      }
    }
  }

  Future<void> setPayment({
    required int orderPk,
    required PaymentType? paymentType,
  }) async {
    if (state is! ResultState) return;
    if (paymentType != null) {
      final payable = await api.markPaidAdminFoodOrder(
        orderPk: orderPk,
        paymentType: paymentType,
      );
      emit(
        ResultState(
          state.result!.map(
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
      await api.markNotPaidAdminFoodOrder(
        orderPk: orderPk,
      );
      emit(
        ResultState(
          state.result!.map(
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
    }
  }
}
