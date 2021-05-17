import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reaxit/blocs/api_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:reaxit/models/food_event.dart';

class FoodState extends Equatable {
  /// This can only be null when [isLoading] or [hasException] is true.
  final FoodEvent? foodEvent;

  /// A message describing why there are no foodEvents.
  final String? message;

  /// A foodEvent is being loaded. If there already is a foodEvent, it is outdated.
  final bool isLoading;

  bool get hasException => message != null;

  @protected
  const FoodState({
    required this.foodEvent,
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
    bool? isLoading,
    String? message,
  }) =>
      FoodState(
        foodEvent: foodEvent ?? this.foodEvent,
        isLoading: isLoading ?? this.isLoading,
        message: message ?? this.message,
      );

  FoodState.foodEvent({required FoodEvent foodEvent})
      : foodEvent = foodEvent,
        message = null,
        isLoading = false;

  FoodState.loading({this.foodEvent})
      : message = null,
        isLoading = true;

  FoodState.failure({required String message})
      : foodEvent = null,
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
      emit(FoodState.foodEvent(foodEvent: event));
    } on ApiException catch (exception) {
      emit(FoodState.failure(message: _failureMessage(exception)));
    }
  }

  String _failureMessage(ApiException exception) {
    switch (exception) {
      case ApiException.noInternet:
        return 'Not connected to the internet.';
      case ApiException.notFound:
        return 'The event does not exist.';
      default:
        return 'An unknown error occurred.';
    }
  }
}
