import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:reaxit/api/exceptions.dart';
import 'package:reaxit/config.dart' as config;
import 'package:sentry_flutter/sentry_flutter.dart';

class TostiApiRepository {
  // TODO: Replace shared utils from apis to a base class.

  /// The [oauth2.Client] used to access the API.
  final oauth2.Client _client;
  final Function() _onLogOut;

  TostiApiRepository({
    /// The [oauth2.Client] used to access the API.
    required oauth2.Client client,

    /// Called when the client can no longer authenticate.
    required Function() onLogOut,
  })  : _client = client,
        _onLogOut = onLogOut;

  void close() {
    _client.close();
  }

  static final Uri _baseUri = Uri(
    scheme: config.tostiApiScheme,
    host: config.tostiApiHost,
    port: config.tostiApiPort,
  );

  static const String _basePath = 'api/v1';

  /// Headers that should be specified on requests with a JSON body.
  static const Map<String, String> _jsonHeader = {
    'Content-type': 'application/json',
  };

  /// Convenience method for building a URL to an API endpoint.
  static Uri _uri({required String path, Map<String, dynamic>? query}) {
    return _baseUri.replace(
      path: path.startsWith('/') ? '$_basePath$path' : '$_basePath/$path',
      queryParameters: query,
    );
  }

  /// Wrapper that utf-8 decodes the body of a response to json.
  static Map<String, dynamic> _jsonDecode(Response response) =>
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

  /// A wrapper for requests that throws only [ApiException]s.
  ///
  /// Translates exceptions that can be thrown by [oauth2.Client.send()],
  /// and throws exceptions based on status codes. By default, all status codes
  /// other than 200, 201 and 204 result in an [ApiException], but this can be
  /// overridden with `allowedStatusCodes`.
  ///
  /// Can be called for example as:
  /// ```dart
  /// final response = await _handleExceptions(() => client.get(uri));
  /// ```
  ///
  /// If you want to manually handle for example 403s, you can use:
  /// ```dart
  /// final response = await _handleExceptions(
  ///   () => client.get(uri),
  ///   allowedStatusCodes: [200, 403],
  /// );
  /// // Use `response.statusCode` here to handle 403.
  /// ```
  Future<Response> _handleExceptions(
    Future<Response> Function() request, {
    List<int> allowedStatusCodes = const [200, 201, 204],
  }) async {
    try {
      final response = await request();
      if (allowedStatusCodes.contains(response.statusCode)) return response;
      switch (response.statusCode) {
        case 401:
          _onLogOut();
          throw ApiException.notLoggedIn;
        case 403:
          throw ApiException.notAllowed;
        case 404:
          throw ApiException.notFound;
        default:
          throw ApiException.unknownError;
      }
    } on oauth2.ExpirationException {
      _onLogOut();
      throw ApiException.notLoggedIn;
    } on oauth2.AuthorizationException {
      _onLogOut();
      throw ApiException.notLoggedIn;
    } on SocketException {
      throw ApiException.noInternet;
    } on FormatException {
      throw ApiException.unknownError;
    } on ClientException {
      throw ApiException.unknownError;
    } on HandshakeException {
      throw ApiException.unknownError;
    } on OSError {
      throw ApiException.unknownError;
    } on ApiException {
      rethrow;
    }
  }

  /// Handler to surround all public methods as follows:
  ///
  /// ```dart
  /// return sandbox(() async {
  ///  // Method content ...
  /// });
  /// ```
  ///
  /// This prevents the ApiRepository from throwing any exceptions other than
  /// ApiExceptions.
  static Future<T> sandbox<T>(Future<T> Function() f) async {
    try {
      return await f();
    } on ApiException {
      rethrow;
    } catch (e) {
      Sentry.captureException(e);
      throw ApiException.unknownError;
    }
  }

}
