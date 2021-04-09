import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Generic class to be used as state when loading
class DetailState<E> extends Equatable {
  /// The result to be shown.
  ///
  /// This can only be null when [isLoading] or [hasException] is true.
  final E? result;

  /// A message describing why there are no results.
  final String? message;

  /// A result is being loaded. If there already is a result, it is outdated.
  final bool isLoading;

  bool get hasException => message != null;

  @protected
  const DetailState({
    required this.result,
    required this.isLoading,
    required this.message,
  }) : assert(
          result != null || isLoading || message != null,
          'result can only be null when isLoading or hasException is true.',
        );

  @override
  List<Object?> get props => [result, message, isLoading];

  @override
  String toString() {
    return 'DetailState<$E>(result: $result, loading: $isLoading, message: $message)';
  }

  DetailState<E> copyWith({E? result, bool? isLoading, String? message}) =>
      DetailState<E>(
        result: result ?? this.result,
        isLoading: isLoading ?? this.isLoading,
        message: message ?? this.message,
      );

  DetailState.result({required E result})
      : result = result,
        message = null,
        isLoading = false;

  DetailState.loading({this.result})
      : message = null,
        isLoading = true;

  DetailState.failure({required String message})
      : result = null,
        message = message,
        isLoading = false;
}
