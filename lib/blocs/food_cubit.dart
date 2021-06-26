import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:reaxit/models/food_event.dart';
import 'package:reaxit/models/food_order.dart';
import 'package:reaxit/models/product.dart';

class FoodState extends Equatable {
  /// This can only be null when [isLoading] or [hasException] is true.
  final FoodEvent? foodEvent;

  /// This can only be null when [isLoading] or [hasException] is true.
  final List<Product>? products;

  /// A message describing why there are no foodEvents.
  final String? message;

  /// A foodEvent is being loaded. If there already is a foodEvent, it is outdated.
  final bool isLoading;

  bool get hasException => message != null;

  @protected
  const FoodState({
    required this.foodEvent,
    required this.products,
    required this.isLoading,
    required this.message,
  }) : assert(
          foodEvent != null || isLoading || message != null,
          'foodEvent can only be null when isLoading or hasException is true.',
        );

  @override
  List<Object?> get props => [foodEvent, message, isLoading];

  FoodState copyWith({
    FoodEvent? foodEvent,
    List<Product>? products,
    bool? isLoading,
    String? message,
  }) =>
      FoodState(
        foodEvent: foodEvent ?? this.foodEvent,
        products: products ?? this.products,
        isLoading: isLoading ?? this.isLoading,
        message: message ?? this.message,
      );

  FoodState.result(
      {required FoodEvent foodEvent, required List<Product> products})
      : foodEvent = foodEvent,
        products = products,
        message = null,
        isLoading = false;

  FoodState.loading({this.foodEvent, this.products})
      : message = null,
        isLoading = true;

  FoodState.failure({required String message})
      : foodEvent = null,
        products = null,
        message = message,
        isLoading = false;
}

class FoodCubit extends Cubit<FoodState> {
  final ApiRepository api;

  FoodCubit(this.api) : super(FoodState.loading());

  Future<void> load(int pk) async {
    emit(state.copyWith(isLoading: true));
    try {
      final event = await api.getFoodEvent(pk);
      final products = await api.getFoodEventProducts(pk);
      emit(FoodState.result(foodEvent: event, products: products.results));
    } on ApiException catch (exception) {
      emit(FoodState.failure(message: _failureMessage(exception)));
    }
  }

  Future<FoodOrder> placeOrder({
    required int eventPk,
    required int productPk,
  }) async {
    final order = await api.placeFoodOrder(
      eventPk: eventPk,
      productPk: productPk,
    );
    await load(eventPk);
    return order;
  }

  Future<FoodOrder> changeOrder({
    required int eventPk,
    required int productPk,
  }) async {
    final order = await api.changeFoodOrder(
      eventPk: eventPk,
      productPk: productPk,
    );
    await load(eventPk);
    return order;
  }

  /// Cancel you order for the [FoodEvent] with the `pk`.
  Future<void> cancelOrder(int pk) async {
    await api.cancelFoodOrder(pk);
    await load(pk);
  }

  /// Pay your order `orderPk` for the event `eventPk` using Thalia Pay.
  Future<void> thaliaPayOrder({
    required int eventPk,
    required int orderPk,
  }) async {
    await api.thaliaPayFoodOrder(foodOrderPk: orderPk);
    await load(eventPk);
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
