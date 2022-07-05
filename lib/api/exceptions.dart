class ApiException implements Exception {
  static const ApiException notFound = ApiException._('Not found');
  static const ApiException unknownError = ApiException._('Unknown error');
  static const ApiException notAllowed = ApiException._('Not allowed');
  static const ApiException notLoggedIn = ApiException._('Not logged in');
  static const ApiException noInternet = ApiException._('No internet');

  final String message;

  const ApiException._(this.message);

  factory ApiException.message(String message) => ApiException._(message);
}
