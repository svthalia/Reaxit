import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/api/api_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/models.dart';

sealed class FoodState extends Equatable {
  const FoodState();

  @override
  List<Object?> get props => [];
}

/// FoodEvent is loading.
class LoadingFoodState extends FoodState {
  final LoadedFoodState? oldState;

  @override
  List<Object?> get props => [oldState];

  LoadingFoodState({FoodState? oldState})
    : oldState = switch (oldState) {
        LoadedFoodState state => state,
        _ => null,
      };
}

/// FoodEvent was unable to load.
class ErrorFoodState extends FoodState {
  final String message;

  @override
  List<Object?> get props => [message];

  const ErrorFoodState(this.message);
}

/// FoodEvent has been loaded.
class LoadedFoodState extends FoodState {
  /// This can only be null when [isLoading] or [hasException] is true.
  final FoodEvent foodEvent;

  /// This can only be null when [isLoading] or [hasException] is true.
  final List<Product> products;

  @override
  List<Object?> get props => [foodEvent, products];

  const LoadedFoodState(this.foodEvent, this.products);
}

class FoodCubit extends Cubit<FoodState> {
  final ApiRepository api;

  int? _foodEventPk;

  FoodCubit(this.api, {int? foodEventPk})
    : _foodEventPk = foodEventPk,
      super(LoadingFoodState());

  Future<void> load() async {
    emit(LoadingFoodState(oldState: state));
    try {
      late final FoodEvent event;
      if (_foodEventPk == null) {
        event = await api.getCurrentFoodEvent();
        _foodEventPk = event.pk;
      } else {
        event = await api.getFoodEvent(_foodEventPk!);
      }

      final products = await api.getFoodEventProducts(_foodEventPk!);
      emit(LoadedFoodState(event, products.results));
    } on ApiException catch (exception) {
      emit(
        ErrorFoodState(
          exception.getMessage(notFound: 'The food event does not exist.'),
        ),
      );
    }
  }

  Future<FoodOrder> placeOrder({required int productPk}) async {
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

  Future<FoodOrder> changeOrder({required int productPk}) async {
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
  Future<void> thaliaPayOrder({required int orderPk}) async {
    await api.thaliaPayFoodOrder(foodOrderPk: orderPk);
    await load();
  }
}
