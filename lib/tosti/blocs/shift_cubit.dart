import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/tosti/models.dart';
import 'package:reaxit/tosti/tosti_api_repository.dart';

class TostiShiftState extends Equatable {
  /// This can only be null when [isLoading] or [hasException] is true.
  final TostiShift? shift;

  /// This can only be null when [isLoading] or [hasException] is true.
  final TostiUser? user;

  /// This can only be null when [isLoading] or [hasException] is true.
  final List<TostiProduct>? products;

  /// This can only be null when [isLoading] or [hasException] is true.
  final List<TostiOrder>? orders;

  /// A message describing why there are no foodEvents.
  final String? message;

  /// A foodEvent is being loaded. If there
  /// already is a foodEvent, it is outdated.
  final bool isLoading;

  bool get hasException => message != null;

  @protected
  const TostiShiftState({
    required this.shift,
    required this.user,
    required this.products,
    required this.orders,
    required this.isLoading,
    required this.message,
  }) : assert(
          (shift != null &&
                  user != null &&
                  products != null &&
                  orders != null) ||
              isLoading ||
              message != null,
          'shift, user, products and orders can only be '
          'null when isLoading or hasException is true.',
        );

  @override
  List<Object?> get props => [message, isLoading];

  TostiShiftState copyWith({
    TostiShift? shift,
    TostiUser? user,
    List<TostiProduct>? products,
    List<TostiOrder>? orders,
    bool? isLoading,
    String? message,
  }) =>
      TostiShiftState(
        shift: shift ?? this.shift,
        user: user ?? this.user,
        products: products ?? this.products,
        orders: orders ?? this.orders,
        isLoading: isLoading ?? this.isLoading,
        message: message ?? this.message,
      );

  const TostiShiftState.result({
    required TostiShift this.shift,
    required TostiUser this.user,
    required List<TostiProduct> this.products,
    required List<TostiOrder> this.orders,
  })  : message = null,
        isLoading = false;

  const TostiShiftState.loading({
    this.shift,
    this.user,
    this.products,
    this.orders,
  })  : message = null,
        isLoading = true;

  const TostiShiftState.failure({required String this.message})
      : shift = null,
        user = null,
        products = null,
        orders = null,
        isLoading = false;
}

class TostiShiftCubit extends Cubit<TostiShiftState> {
  final TostiApiRepository api;

  TostiShiftCubit(this.api) : super(const TostiShiftState.loading());

  Future<void> load(int id) async {
    emit(state.copyWith(isLoading: true));
    try {
      final shiftFuture = api.getShift(id);
      final productsFuture = api.getShiftProducts(
        id,
        orderable: true,
        limit: 9999,
      );
      final ordersFuture = api.getShiftOrders(id, limit: 9999);

      final TostiUser user = state.user ?? await api.getMe();

      final shift = await shiftFuture;
      final products = await productsFuture;
      final orders = await ordersFuture;

      emit(TostiShiftState.result(
        shift: shift,
        user: user,
        products: products.results,
        orders: orders.results,
      ));
    } on ApiException catch (exception) {
      emit(TostiShiftState.failure(message: exception.message));
    }
  }

  Future<TostiOrder> order(int shiftId, TostiProduct product) async {
    final order = await api.placeOrder(shiftId, product);
    await load(shiftId);
    return order;
  }
}
