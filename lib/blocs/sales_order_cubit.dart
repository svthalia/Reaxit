import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/blocs/detail_state.dart';
import 'package:reaxit/models.dart';
import 'package:reaxit/models/shift.dart';

sealed class _SalesOrder extends Equatable {
  const _SalesOrder();

  @override
  List<Object?> get props => [];
}

typedef SalesOrderState = DetailState<_SalesOrder>;

class LocalOrderState extends _SalesOrder {
  final List<SalesOrderItem> items;

  @override
  List<Object?> get props => [items];

  const LocalOrderState({this.items = const []});
}

class RemoteOrderState extends _SalesOrder {
  final SalesOrder order;
  final bool synced;

  @override
  List<Object?> get props => [order, synced];

  const RemoteOrderState(this.order, this.synced);
}

class SalesOrderCubit extends Cubit<SalesOrderState> {
  final ApiRepository api;

  // We now know that there is in fact no in flight requests.
  // DO NOT await, until we enter:
  // inflight = Future.sync(() {
  //   return api.updateSalesOrder(orderpk: order.pk, items: items);
  // });
  // Doing so will allow another call to `submit` to come in
  // and work on an old state. There is then a race condition on the
  // concurrent calls to `emit` and on the concurrent http requests.
  // This can cause a desync between client and server, which is BAD.

  Future<void> inflight = Future.value();

  int? shiftpk;
  String? pk;

  SalesOrderCubit.fromExisting(this.api, SalesOrder order)
    : pk = order.pk,
      shiftpk = order.shift,
      super(ResultState(RemoteOrderState(order, true)));

  SalesOrderCubit.fromPK(this.api, this.pk) : super(LoadingState());

  Future<void> claim() async {
    String? pk = this.pk;
    if (pk != null) {
      try {
        final order = await api.claimSalesOrder(pk: pk);
        emit(ResultState(RemoteOrderState(order, true)));
      } on ApiException catch (exception) {
        emit(
          ErrorState(
            exception.getMessage(notFound: 'The order does not exist.'),
          ),
        );
      }
    }
  }

  List<SalesOrderItem>? _changeItems(
    String product,
    int Function(int) change,
    List<SalesOrderItem> items,
  ) {
    final int index = items.indexWhere((item) => item.product == product);
    if (index >= 0) {
      if (change(items[index].amount) < 0) {
        return null;
      }
      items[index] = items[index].copyWithAmount(change(items[index].amount));
    } else {
      if (change(0) < 0) {
        return null;
      }
      items.add(SalesOrderItem(product, change(0), ''));
    }
    return items;
  }

  void _changeOrder(String product, int Function(int) change) {
    // Don't go adding products that don't exist
    switch (state) {
      case ResultState(result: LocalOrderState(items: final items)):
        final newItems = _changeItems(product, change, [...items]);
        if (newItems != null) {
          emit(ResultState(LocalOrderState(items: newItems)));
        }
      case ResultState(result: RemoteOrderState(order: final order)):
        final newItems = _changeItems(product, change, order.orderItems);
        if (newItems != null) {
          emit(
            ResultState(RemoteOrderState(order.copyWithItems(newItems), false)),
          );
        }
      case _:
        return;
    }
  }

  // Submit/update the order to the server
  Future<void> submit() async {
    switch (state) {
      case ResultState(result: LocalOrderState(items: final items)):
        await inflight;
        inflight = Future.sync(() async {
          await api.createSalesOrder(shiftpk: shiftpk!, items: items).then((
            order,
          ) {
            pk = order.pk;
            emit(ResultState(RemoteOrderState(order, true)));
          });
        });
        return await inflight;
      case ResultState(result: RemoteOrderState(order: final order)):
        await inflight;
        inflight = Future.sync(() async {
          Future f = api.updateSalesOrder(
            orderpk: order.pk,
            items: order.orderItems,
          );
          emit(ResultState(RemoteOrderState(order, true)));
          await f;
        });
        return await inflight;
      case _:
        return;
    }
  }

  // products are identified by name??? API seems to say so.
  void addOrder(String product) {
    return _changeOrder(product, (amount) => amount + 1);
  }

  // products are identified by name??? API seems to say so.
  void subOrder(String product) {
    return _changeOrder(product, (amount) => amount - 1);
  }

  static bool checkIfPaid(SalesOrderState s) {
    switch (s) {
      case ResultState(result: RemoteOrderState(order: final order)):
        return order.isPaid;
      case _:
        return false;
    }
  }

  static bool checkIfSynced(SalesOrderState s) {
    switch (s) {
      case ResultState(result: RemoteOrderState(synced: final synced)):
        return synced;
      case _:
        return false;
    }
  }

  bool isPaid() => checkIfPaid(state);
  bool isSynced() => checkIfSynced(state);

  Future<void> cancelOrder() async {
    switch (state) {
      case ResultState(result: RemoteOrderState(order: final order)):
        api.deleteSalesOrder(orderpk: order.pk);
        pk = null;
        emit(ResultState(LocalOrderState()));
      case _:
        return;
    }
  }

  Future<void> paySalesOrder() async {
    String? pk = this.pk;
    if (pk != null) {
      await api.thaliaPaySalesOrder(salesOrderPk: pk);
    }
  }
}

class ShiftOrder extends Equatable {
  final Shift? shift;
  final SalesOrder? order;

  @override
  List<Object?> get props => [shift, order];

  const ShiftOrder({this.shift, this.order});
}

typedef SalesShiftState = DetailState<ShiftOrder>;

class SalesShiftCubit extends Cubit<SalesShiftState> {
  final ApiRepository api;

  final int shiftpk;
  String? pk;

  SalesShiftCubit(this.api, this.shiftpk) : super(LoadingState()) {
    reload();
  }

  Future<void> reload() async {
    return api
        .getSalesShift(shiftpk: shiftpk)
        .then((s) async {
          switch (state) {
            case LoadingState():
            case ErrorState(message: _):
              ListResponse<ListSalesOrder> orders = await api.getSalesOrders(
                shiftpk: shiftpk,
              );
              if (orders.count == 0) {
                emit(ResultState(ShiftOrder(shift: s)));
              } else if (orders.count == 1) {
                SalesOrder order = await api.getSalesOrder(
                  orderpk: orders.results[0].pk,
                );
                emit(ResultState(ShiftOrder(shift: s, order: order)));
              } else {
                emit(
                  ErrorState(
                    'You have multiple orders for this shift. This is currently unsupported in the Thaliapp.\n\n'
                    'Please continue to the website to manage your orders',
                  ),
                );
              }
            case ResultState(result: ShiftOrder(shift: _, order: final order)):
              emit(ResultState(ShiftOrder(shift: s, order: order)));
          }
        })
        .onError<ApiException>((e, _) {
          emit(ErrorState(e.getMessage()));
        });
  }

  Future<void> setOrder() async {
    switch (state) {
      case ResultState(result: ShiftOrder(shift: _, order: final order!)):
        api.updateSalesOrder(orderpk: order.pk, items: order.orderItems);
      case _:
        return;
    }
  }

  Future<void> cancelOrder() async {
    switch (state) {
      case ResultState(result: ShiftOrder(shift: _, order: final order!)):
        api.updateSalesOrder(orderpk: order.pk, items: []);
      case _:
        return;
    }
  }

  Future<void> paySalesOrder() async {
    String? pk = this.pk;
    if (pk != null) {
      await api.thaliaPaySalesOrder(salesOrderPk: pk);
    }
  }
}
