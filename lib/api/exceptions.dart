/// An enum-like class for custom exceptions that are thrown by the API.
///
/// This class provides a number of enum-like static constants representing
/// the various error types that can be thrown by the API. Some of these have
/// a good default message, others default to "An unknown error occurred."
///
/// If none of the constants are suitable, an [ApiException.message] can be
/// used to create an exception with a custom message.
class ApiException implements Exception {
  static const unknownError = _UnknownException();
  static const notFound = _NotFoundException();
  static const notAllowed = _NotAllowedException();
  static const notLoggedIn = _NotLoggedInException();
  static const noInternet = _NoInternetException();

  const ApiException._([this._message]);
  factory ApiException.message(String message) => _MessageException(message);

  final String? _message;
  String get message => _message ?? 'An unknown error occurred.';

  bool get isMessage => this is _MessageException;

  /// Returns a message describing the exceptions, with the possibility
  /// to specify custom messages for exceptions with no good default.
  ///
  /// For example:
  /// ```dart
  /// exception.getMessage(
  ///  notFound: 'The event does not exist.',
  /// )
  /// ```
  /// This will return 'The event does not exist.' if the exception is
  /// [ApiException.notFound], one of the default messages otherwise.
  /// Without specifying `notFound`, the default message would also be used for
  /// [ApiException.notFound].
  String getMessage({
    String? notFound,
    String? notAllowed,
    String? unknown,
  }) {
    if (this is _NotFoundException) return notFound ?? message;
    if (this is _NotAllowedException) return notAllowed ?? message;
    if (this is _UnknownException) return unknown ?? message;
    return message;
  }
}

class _UnknownException extends ApiException {
  const _UnknownException() : super._();
}

class _NotFoundException extends ApiException {
  const _NotFoundException() : super._();
}

class _NotAllowedException extends ApiException {
  const _NotAllowedException() : super._();
}

class _NotLoggedInException extends ApiException {
  const _NotLoggedInException() : super._('You are not logged in.');
}

class _NoInternetException extends ApiException {
  const _NoInternetException() : super._('Could not connect to the server.');
}

class _MessageException extends ApiException {
  const _MessageException(String message) : super._(message);
}
