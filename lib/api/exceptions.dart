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

  const ApiException._(this._message);
  factory ApiException.message(String message) => _MessageException(message);

  final String _message;
  String get message => _message;

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
    String? unknown,
    String? notFound,
    String? notAllowed,
    String? notLoggedIn,
    String? noInternet,
    String? serverError,
  }) {
    switch (runtimeType) {
      case _UnknownException:
        return unknown ?? message;
      case _NotFoundException:
        return notFound ?? message;
      case _NotAllowedException:
        return notAllowed ?? message;
      case _NotLoggedInException:
        return notLoggedIn ?? message;
      case _NoInternetException:
        return notAllowed ?? message;
      case _InternalServerException:
        return serverError ?? message;
      default:
        return message;
    }
  }
}

class _UnknownException extends ApiException {
  const _UnknownException() : super._('An unknown error occurred.');
}

class _NotFoundException extends ApiException {
  const _NotFoundException() : super._('Could not find this.');
}

class _NotAllowedException extends ApiException {
  const _NotAllowedException() : super._('You are not allowed to view this.');
}

class _NotLoggedInException extends ApiException {
  const _NotLoggedInException() : super._('You are not logged in.');
}

class _NoInternetException extends ApiException {
  const _NoInternetException() : super._('Could not connect to the server.');
}

class _InternalServerException extends ApiException {
  const _InternalServerException() : super._('Server error.');
}

class _MessageException extends ApiException {
  const _MessageException(String message) : super._(message);
}
