import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:reaxit/api/exceptions.dart';
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

  /// A foodEvent is being loaded. If there
  /// already is a foodEvent, it is outdated.
  final bool isLoading;

  bool get hasException => message != null;

  @protected
  const FoodState({
    required this.foodEvent,
    required this.products,
    required this.isLoading,
    required this.message,
  }) : assert(
          (foodEvent != null && products != null) ||
              isLoading ||
              message != null,
          'foodEvent and products can only be null '
          'when isLoading or hasException is true.',
        );

  @override
  List<Object?> get props => [foodEvent, products, message, isLoading];

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

  const FoodState.result({
    required FoodEvent this.foodEvent,
    required List<Product> this.products,
  })  : message = null,
        isLoading = false;

  const FoodState.loading({this.foodEvent, this.products})
      : message = null,
        isLoading = true;

  const FoodState.failure({required String this.message})
      : foodEvent = null,
        products = null,
        isLoading = false;
}

class FoodCubit extends Cubit<FoodState> {
  final ApiRepository api;

  int? _foodEventPk;

  FoodCubit(this.api, {int? foodEventPk})
      : _foodEventPk = foodEventPk,
        super(const FoodState.loading());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      late final FoodEvent event;
      if (_foodEventPk == null) {
        event = await api.getCurrentFoodEvent();
        _foodEventPk = event.pk;
      } else {
        event = await api.getFoodEvent(_foodEventPk!);
      }

      final products = await api.getFoodEventProducts(_foodEventPk!);
      emit(FoodState.result(foodEvent: event, products: products.results));
    } on ApiException catch (exception) {
      emit(FoodState.failure(
        message: exception.getMessage(
          notFound: 'The food event does not exist.',
        ),
      ));
    }
  }

  Future<FoodOrder> placeOrder({
    required int productPk,
  }) async {
    if (_foodEventPk == null) {
      final event = await api.getCurrentFoodEvent();
      _foodEventPk = event.pk;
    }

    final order = await api.placeFoodOrder(
      eventPk: _foodEventPk!,
      productPk: productPk,
    );
    await load();
    return order;
  }

  Future<FoodOrder> changeOrder({
    required int productPk,
  }) async {
    if (_foodEventPk == null) {
      final event = await api.getCurrentFoodEvent();
      _foodEventPk = event.pk;
    }

    final order = await api.changeFoodOrder(
      eventPk: _foodEventPk!,
      productPk: productPk,
    );
    await load();
    return order;
  }

  /// Cancel you order.
  Future<void> cancelOrder() async {
    if (_foodEventPk == null) {
      final event = await api.getCurrentFoodEvent();
      _foodEventPk = event.pk;
    }
    await api.cancelFoodOrder(_foodEventPk!);
    await load();
  }

  /// Pay your order `orderPk` using Thalia Pay.
  Future<void> thaliaPayOrder({
    required int orderPk,
  }) async {
    await api.thaliaPayFoodOrder(foodOrderPk: orderPk);
    await load();
  }
}
